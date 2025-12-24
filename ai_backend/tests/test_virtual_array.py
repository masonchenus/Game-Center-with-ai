import unittest
from ai_backend.virtual_array import VirtualLargeArray


class TestVirtualLargeArray(unittest.TestCase):
    def test_length_and_indexing(self):
        v = VirtualLargeArray(100, seed="test-seed")
        self.assertEqual(len(v), 100)
        # Check deterministic value at index 0 and 1
        a0 = v[0]
        a1 = v[1]
        self.assertIsInstance(a0, int)
        self.assertIsInstance(a1, int)
        self.assertNotEqual(a0, a1)

    def test_slice_and_sample(self):
        v = VirtualLargeArray(50, seed="test-sample")
        s = v[5:10]
        self.assertEqual(len(s), 5)
        sample = v.sample(3, start=2)
        self.assertEqual(len(sample), 3)

    def test_negative_index_and_bounds(self):
        v = VirtualLargeArray(10)
        self.assertEqual(v[-1], v[9])
        with self.assertRaises(IndexError):
            _ = v[10]


if __name__ == "__main__":
    unittest.main()
