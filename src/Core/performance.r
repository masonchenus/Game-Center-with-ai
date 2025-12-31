// ============================================================================
// Game Center Performance Monitoring Module
// Written in Rust for high-performance metrics tracking
// Used by both game center frontend and ai_backend
// ============================================================================

// ============================================================================
// PERFORMANCE METRICS STRUCTURES
// ============================================================================

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct PerformanceMetrics {
    pub timestamp: u64,
    pub cpu_usage: f64,
    pub memory_usage: f64,
    pub gpu_usage: f64,
    pub frame_rate: f64,
    pub frame_time_ms: f64,
    pub render_time_ms: f64,
    pub update_time_ms: f64,
    pub input_latency_ms: f64,
    pub network_latency_ms: f64,
}

impl Default for PerformanceMetrics {
    fn default() -> Self {
        PerformanceMetrics {
            timestamp: 0,
            cpu_usage: 0.0,
            memory_usage: 0.0,
            gpu_usage: 0.0,
            frame_rate: 0.0,
            frame_time_ms: 0.0,
            render_time_ms: 0.0,
            update_time_ms: 0.0,
            input_latency_ms: 0.0,
            network_latency_ms: 0.0,
        }
    }
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct GamePerformanceProfile {
    pub game_id: String,
    pub average_fps: f64,
    pub fps_variance: f64,
    pub min_frame_time: f64,
    pub max_frame_time: f64,
    pub percentile_95_frame_time: f64,
    pub total_playtime_ms: u64,
    pub frame_drops: u32,
    pub performance_score: u8,
}

// ============================================================================
// FRAME TIME TRACKER
// ============================================================================

pub struct FrameTimeTracker {
    frame_times: Vec<f64>,
    max_samples: usize,
    last_frame_time: Instant,
    frame_count: u32,
    fps_update_interval: Duration,
    last_fps_update: Instant,
    current_fps: f64,
}

impl FrameTimeTracker {
    pub fn new(max_samples: usize) -> Self {
        FrameTimeTracker {
            frame_times: Vec::with_capacity(max_samples),
            max_samples,
            last_frame_time: Instant::now(),
            frame_count: 0,
            fps_update_interval: Duration::from_millis(500),
            last_fps_update: Instant::now(),
            current_fps: 0.0,
        }
    }

    pub fn record_frame(&mut self) -> f64 {
        let now = Instant::now();
        let elapsed = now.duration_since(self.last_frame_time);
        let frame_time_ms = elapsed.as_secs_f64() * 1000.0;
        
        self.frame_times.push(frame_time_ms);
        if self.frame_times.len() > self.max_samples {
            self.frame_times.remove(0);
        }
        
        self.last_frame_time = now;
        self.frame_count += 1;
        
        // Update FPS every interval
        if now.duration_since(self.last_fps_update) >= self.fps_update_interval {
            let elapsed_secs = now.duration_since(self.last_fps_update).as_secs_f64();
            self.current_fps = self.frame_count as f64 / elapsed_secs;
            self.frame_count = 0;
            self.last_fps_update = now;
        }
        
        frame_time_ms
    }

    pub fn current_fps(&self) -> f64 {
        self.current_fps
    }

    pub fn average_frame_time(&self) -> f64 {
        if self.frame_times.is_empty() {
            return 0.0;
        }
        self.frame_times.iter().sum::<f64>() / self.frame_times.len() as f64
    }

    pub fn percentile_frame_time(&self, percentile: f64) -> f64 {
        if self.frame_times.is_empty() {
            return 0.0;
        }
        
        let mut sorted = self.frame_times.clone();
        sorted.sort_by(|a, b| a.partial_cmp(b).unwrap());
        
        let index = ((percentile / 100.0) * (sorted.len() - 1) as f64).round() as usize;
        sorted[index]
    }

    pub fn frame_time_variance(&self) -> f64 {
        if self.frame_times.len() < 2 {
            return 0.0;
        }
        
        let mean = self.average_frame_time();
        let squared_diffs: f64 = self.frame_times.iter()
            .map(|t| (t - mean).powi(2))
            .sum();
        
        squared_diffs / (self.frame_times.len() - 1) as f64
    }

    pub fn detect_frame_drops(&self, threshold_ms: f64) -> Vec<usize> {
        self.frame_times.iter()
            .enumerate()
            .filter(|(_, &t)| t > threshold_ms)
            .map(|(i, _)| i)
            .collect()
    }

    pub fn reset(&mut self) {
        self.frame_times.clear();
        self.frame_count = 0;
        self.last_frame_time = Instant::now();
        self.last_fps_update = Instant::now();
        self.current_fps = 0.0;
    }
}

// ============================================================================
// PERFORMANCE MONITOR
// ============================================================================

pub struct PerformanceMonitor {
    metrics: Arc<RwLock<PerformanceMetrics>>,
    frame_tracker: FrameTimeTracker,
    sampling_rate: Duration,
    last_sample: Instant,
    history: Vec<PerformanceMetrics>,
    max_history: usize,
}

impl PerformanceMonitor {
    pub fn new(sampling_rate_ms: u64, max_history_samples: usize) -> Self {
        PerformanceMonitor {
            metrics: Arc::new(RwLock::new(PerformanceMetrics::default())),
            frame_tracker: FrameTimeTracker::new(300),
            sampling_rate: Duration::from_millis(sampling_rate_ms),
            last_sample: Instant::now(),
            history: Vec::with_capacity(max_history_samples),
            max_history: max_history_samples,
        }
    }

    pub fn start_frame(&mut self) {
        self.frame_tracker.record_frame();
    }

    pub fn end_frame(&mut self) {
        let frame_time = self.frame_tracker.average_frame_time();
        let mut metrics = self.metrics.write();
        metrics.frame_time_ms = frame_time;
        metrics.frame_rate = self.frame_tracker.current_fps();
    }

    pub fn sample(&mut self) -> Option<PerformanceMetrics> {
        if Instant::now().duration_since(self.last_sample) < self.sampling_rate {
            return None;
        }
        
        let mut metrics = self.metrics.write();
        metrics.timestamp = now_millis();
        metrics.frame_rate = self.frame_tracker.current_fps();
        metrics.frame_time_ms = self.frame_tracker.average_frame_time();
        
        // Sample system metrics
        if let Some(cpu) = sample_cpu_usage() {
            metrics.cpu_usage = cpu;
        }
        if let Some(mem) = sample_memory_usage() {
            metrics.memory_usage = mem;
        }
        
        let snapshot = metrics.clone();
        
        self.history.push(snapshot.clone());
        if self.history.len() > self.max_history {
            self.history.remove(0);
        }
        
        self.last_sample = Instant::now();
        Some(snapshot)
    }

    pub fn get_metrics(&self) -> PerformanceMetrics {
        self.metrics.read().clone()
    }

    pub fn get_history(&self) -> &[PerformanceMetrics] {
        &self.history
    }

    pub fn calculate_profile(&self, game_id: &str) -> GamePerformanceProfile {
        let frame_times: Vec<f64> = self.history.iter()
            .map(|m| m.frame_time_ms)
            .filter(|&t| t > 0.0)
            .collect();
        
        let fps_values: Vec<f64> = self.history.iter()
            .map(|m| m.frame_rate)
            .filter(|&f| f > 0.0)
            .collect();
        
        GamePerformanceProfile {
            game_id: game_id.to_string(),
            average_fps: if !fps_values.is_empty() {
                fps_values.iter().sum::<f64>() / fps_values.len() as f64
            } else {
                0.0
            },
            fps_variance: Self::variance(&fps_values),
            min_frame_time: if !frame_times.is_empty() {
                frame_times.iter().cloned().fold(f64::MAX, f64::min)
            } else {
                0.0
            },
            max_frame_time: if !frame_times.is_empty() {
                frame_times.iter().cloned().fold(f64::MIN, f64::max)
            } else {
                0.0
            },
            percentile_95_frame_time: self.frame_tracker.percentile_frame_time(95.0),
            total_playtime_ms: self.history.len() as u64 * self.sampling_rate.as_millis() as u64,
            frame_drops: self.frame_tracker.detect_frame_drops(33.33).len() as u32,
            performance_score: self.calculate_score(),
        }
    }

    fn calculate_score(&self) -> u8 {
        let fps = self.frame_tracker.current_fps();
        let avg_frame_time = self.frame_tracker.average_frame_time();
        let frame_drops = self.frame_tracker.detect_frame_drops(33.33).len();
        
        let fps_score = if fps >= 60 { 40 } 
        else if fps >= 30 { 30 + ((fps - 30) / 30.0 * 10.0) as u8 }
        else { (fps / 30.0 * 30.0) as u8 };
        
        let stability_score = if avg_frame_time < 16.67 { 30 }
        else if avg_frame_time < 33.33 { 20 + ((33.33 - avg_frame_time) / 16.66 * 10.0) as u8 }
        else { (33.33 / avg_frame_time * 20.0) as u8 };
        
        let drop_penalty = (frame_drops.min(10) as u8) * 3;
        
        (fps_score + stability_score - drop_penalty).clamp(0, 100) as u8
    }

    fn variance(values: &[f64]) -> f64 {
        if values.len() < 2 {
            return 0.0;
        }
        let mean = values.iter().sum::<f64>() / values.len() as f64;
        let squared_diffs: f64 = values.iter()
            .map(|v| (v - mean).powi(2))
            .sum();
        squared_diffs / (values.len() - 1) as f64
    }
}

// ============================================================================
// GPU PERFORMANCE TRACKER
// ============================================================================

pub struct GPUPerformanceTracker {
    vulkan_device: Option<VulkanDevice>,
    directx_device: Option<DirectXDevice>,
    frame_times: Vec<f64>,
    vertex_count: u32,
    triangle_count: u32,
    draw_calls: u32,
}

impl GPUPerformanceTracker {
    pub fn new() -> Self {
        GPUPerformanceTracker {
            #[cfg(target_os = "windows")]
            {
                let directx = DirectXDevice::new().ok();
                GPUPerformanceTracker {
                    vulkan_device: None,
                    directx_device: directx,
                    frame_times: Vec::new(),
                    vertex_count: 0,
                    triangle_count: 0,
                    draw_calls: 0,
                }
            }
            #[cfg(not(target_os = "windows"))]
            {
                let vulkan = VulkanDevice::new().ok();
                GPUPerformanceTracker {
                    vulkan_device: vulkan,
                    directx_device: None,
                    frame_times: Vec::new(),
                    vertex_count: 0,
                    triangle_count: 0,
                    draw_calls: 0,
                }
            }
        }
    }

    pub fn begin_frame(&mut self) {
        self.vertex_count = 0;
        self.triangle_count = 0;
        self.draw_calls = 0;
    }

    pub fn record_draw_call(&mut self, vertex_count: u32, triangle_count: u32) {
        self.vertex_count += vertex_count;
        self.triangle_count += triangle_count;
        self.draw_calls += 1;
    }

    pub fn end_frame(&mut self) -> Option<f64> {
        let render_time = match &mut self.vulkan_device {
            Some(device) => device.end_frame(),
            None => match &mut self.directx_device {
                Some(device) => device.end_frame(),
                None => None,
            },
        };
        
        if let Some(time) = render_time {
            self.frame_times.push(time);
            if self.frame_times.len() > 300 {
                self.frame_times.remove(0);
            }
        }
        
        render_time
    }

    pub fn gpu_usage(&self) -> f64 {
        match &self.vulkan_device {
            Some(device) => device.queue_graphics(),
            None => match &self.directx_device {
                Some(device) => device.gpu_usage(),
                None => 0.0,
            },
        }
    }

    pub fn video_memory_used(&self) -> u64 {
        match &self.vulkan_device {
            Some(device) => device.memory_used(),
            None => match &self.directx_device {
                Some(device) => device.video_memory_used(),
                None => 0,
            },
        }
    }
}

// ============================================================================
// NETWORK LATENCY TRACKER
// ============================================================================

pub struct LatencyTracker {
    ping_history: Vec<f64>,
    jitter_history: Vec<f64>,
    packet_loss: u32,
    packets_sent: u32,
    packets_received: u32,
    max_history: usize,
}

impl LatencyTracker {
    pub fn new(max_history: usize) -> Self {
        LatencyTracker {
            ping_history: Vec::with_capacity(max_history),
            jitter_history: Vec::with_capacity(max_history),
            packet_loss: 0,
            packets_sent: 0,
            packets_received: 0,
            max_history,
        }
    }

    pub fn record_ping(&mut self, latency_ms: f64) {
        self.packets_received += 1;
        self.ping_history.push(latency_ms);
        
        if self.ping_history.len() > self.max_history {
            self.ping_history.remove(0);
        }
        
        // Calculate jitter
        if self.ping_history.len() >= 2 {
            let jitter = (self.ping_history[self.ping_history.len() - 1] 
                        - self.ping_history[self.ping_history.len() - 2]).abs();
            self.jitter_history.push(jitter);
            if self.jitter_history.len() > self.max_history {
                self.jitter_history.remove(0);
            }
        }
    }

    pub fn record_packet_loss(&mut self) {
        self.packet_loss += 1;
    }

    pub fn increment_sent(&mut self) {
        self.packets_sent += 1;
    }

    pub fn average_latency(&self) -> f64 {
        if self.ping_history.is_empty() {
            return 0.0;
        }
        self.ping_history.iter().sum::<f64>() / self.ping_history.len() as f64
    }

    pub fn average_jitter(&self) -> f64 {
        if self.jitter_history.is_empty() {
            return 0.0;
        }
        self.jitter_history.iter().sum::<f64>() / self.jitter_history.len() as f64
    }

    pub fn packet_loss_rate(&self) -> f64 {
        if self.packets_sent == 0 {
            return 0.0;
        }
        self.packet_loss as f64 / self.packets_sent as f64 * 100.0
    }

    pub fn percentile_latency(&self, percentile: f64) -> f64 {
        if self.ping_history.is_empty() {
            return 0.0;
        }
        
        let mut sorted = self.ping_history.clone();
        sorted.sort_by(|a, b| a.partial_cmp(b).unwrap());
        
        let index = ((percentile / 100.0) * (sorted.len() - 1) as f64).round() as usize;
        sorted[index]
    }

    pub fn quality_score(&self) -> u8 {
        let latency_score = if self.average_latency() < 50 { 40 }
        else if self.average_latency() < 100 { 30 + ((100 - self.average_latency()) / 50.0 * 10.0) as u8 }
        else { (200 - self.average_latency()) / 150.0 * 30.0 as u8 };
        
        let jitter_score = if self.average_jitter() < 10 { 30 }
        else if self.average_jitter() < 30 { 20 + ((30 - self.average_jitter()) / 20.0 * 10.0) as u8 }
        else { (30.0 / self.average_jitter() * 20.0) as u8 };
        
        let loss_score = if self.packet_loss_rate() < 1.0 { 30 }
        else if self.packet_loss_rate() < 5.0 { 20 + ((5 - self.packet_loss_rate()) / 4.0 * 10.0) as u8 }
        else { (5.0 / self.packet_loss_rate() * 20.0) as u8 };
        
        (latency_score + jitter_score + loss_score).clamp(0, 100) as u8
    }
}

// ============================================================================
// THREAD POOL MONITOR
// ============================================================================

pub struct ThreadPoolMonitor {
    thread_usage: Vec<f64>,
    queue_length: Arc<AtomicUsize>,
    active_tasks: Arc<AtomicUsize>,
    completed_tasks: Arc<AtomicUsize>,
    total_tasks: Arc<AtomicUsize>,
}

impl ThreadPoolMonitor {
    pub fn new(num_threads: usize) -> Self {
        ThreadPoolMonitor {
            thread_usage: vec![0.0; num_threads],
            queue_length: Arc::new(AtomicUsize::new(0)),
            active_tasks: Arc::new(AtomicUsize::new(0)),
            completed_tasks: Arc::new(AtomicUsize::new(0)),
            total_tasks: Arc::new(AtomicUsize::new(0)),
        }
    }

    pub fn queue_length(&self) -> usize {
        self.queue_length.load(Ordering::SeqCst)
    }

    pub fn active_tasks(&self) -> usize {
        self.active_tasks.load(Ordering::SeqCst)
    }

    pub fn completed_tasks(&self) -> usize {
        self.completed_tasks.load(Ordering::SeqCst)
    }

    pub fn throughput(&self, window_secs: f64) -> f64 {
        let completed = self.completed_tasks.load(Ordering::SeqCst);
        completed as f64 / window_secs
    }

    pub fn average_queue_time(&self) -> f64 {
        // Simplified - in real implementation would track individual task times
        let queue_len = self.queue_length() as f64;
        let active = self.active_tasks() as f64;
        if active > 0 {
            queue_len / active * 16.67 // Approximate based on 60fps
        } else {
            0.0
        }
    }
}

// ============================================================================
// OPTIMIZATION RECOMMENDATIONS
// ============================================================================

pub struct OptimizationAdvisor;

impl OptimizationAdvisor {
    pub fn analyze_and_recommend(metrics: &PerformanceMetrics, profile: &GamePerformanceProfile) -> Vec<OptimizationRecommendation> {
        let mut recommendations = Vec::new();
        
        // FPS recommendations
        if profile.average_fps < 30.0 {
            recommendations.push(OptimizationRecommendation {
                category: OptimizationCategory::Graphics,
                priority: Priority::Critical,
                description: "Average FPS below 30. Consider reducing graphics quality.".to_string(),
                expected_improvement: "15-25% FPS increase".to_string(),
            });
        } else if profile.average_fps < 50.0 {
            recommendations.push(OptimizationRecommendation {
                category: OptimizationCategory::Graphics,
                priority: Priority::Medium,
                description: "FPS could be improved for smoother gameplay.".to_string(),
                expected_improvement: "10-15% FPS increase".to_string(),
            });
        }
        
        // Frame time variance
        if profile.fps_variance > 100.0 {
            recommendations.push(OptimizationRecommendation {
                category: OptimizationCategory::Stability,
                priority: Priority::High,
                description: "High frame time variance causes stuttering.".to_string(),
                expected_improvement: "More consistent frame times".to_string(),
            });
        }
        
        // Memory usage
        if metrics.memory_usage > 80.0 {
            recommendations.push(OptimizationRecommendation {
                category: OptimizationCategory::Memory,
                priority: Priority::High,
                description: "High memory usage may cause GC pauses.".to_string(),
                expected_improvement: "Reduced memory pressure".to_string(),
            });
        }
        
        recommendations
    }
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct OptimizationRecommendation {
    pub category: OptimizationCategory,
    pub priority: Priority,
    pub description: String,
    pub expected_improvement: String,
}

#[derive(Debug, Clone, Serialize, Deserialize, PartialEq)]
pub enum OptimizationCategory {
    Graphics,
    Memory,
    CPU,
    Network,
    Stability,
    Gameplay,
}

#[derive(Debug, Clone, Serialize, Deserialize, PartialEq)]
pub enum Priority {
    Critical,
    High,
    Medium,
    Low,
}

// ============================================================================
// HELPER FUNCTIONS
// ============================================================================

fn now_millis() -> u64 {
    let now = std::time::SystemTime::now();
    now.duration_since(std::time::UNIX_EPOCH)
        .unwrap_or(std::time::Duration::from_secs(0))
        .as_millis() as u64
}

fn sample_cpu_usage() -> Option<f64> {
    // Platform-specific implementation would go here
    // For now, return simulated value
    Some(45.0)
}

fn sample_memory_usage() -> Option<f64> {
    // Platform-specific implementation would go here
    // Returns percentage of available memory used
    Some(60.0)
}

// ============================================================================
// EXPORTS
// ============================================================================

pub use self::{
    PerformanceMetrics,
    GamePerformanceProfile,
    PerformanceMonitor,
    FrameTimeTracker,
    GPUPerformanceTracker,
    LatencyTracker,
    ThreadPoolMonitor,
    OptimizationAdvisor,
    OptimizationRecommendation,
    OptimizationCategory,
    Priority,
};

