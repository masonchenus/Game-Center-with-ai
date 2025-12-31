# Repository Reorganization TODO

## Plan Approved by User: ✅ YES

---

## Phase 1: Configuration Files ✅ COMPLETED
- [x] 1.1 Create `config/` directory
- [x] 1.2 Move `.babelrc` to config/
- [x] 1.3 Move `.browserslistrc` to config/
- [x] 1.4 Move `.editorconfig` to config/
- [x] 1.5 Move `.eslintrc.json` to config/
- [x] 1.6 Move `.htaccess` to config/
- [x] 1.7 Move `.nojekyll` to config/
- [x] 1.8 Move `.prettierrc` to config/
- [x] 1.9 Move `biome.json` to config/
- [x] 1.10 Move `coderabbit.markdownlint-cli2.jsonc` to config/
- [x] 1.11 Move `netlify.toml` to config/
- [x] 1.12 Move `ruff.toml` to config/
- [x] 1.13 Move `vercel.json` to config/

## Phase 2: Documentation Files ✅ COMPLETED
- [x] 2.1 Move `LANGUAGES_SCATTERING_PLAN.md` to docs/
- [x] 2.2 Move `content_language_stats.json` to docs/
- [x] 2.3 Move `file_extension_stats.json` to docs/

## Phase 3: Merge Update Overviews ✅ COMPLETED
- [x] 3.1 Move all version files to docs/changelog/
- [x] 3.2 Move create_pdfs.py to docs/changelog/
- [x] 3.3 Move billing.json to billing/
- [x] 3.4 Move stats.json to stats/
- [x] 3.5 Remove `Update Overviews & pdf/` directory

## Phase 4: Stats Consolidation ✅ COMPLETED
- [x] 4.1 Move root-level `stats.json` to stats/
- [x] 4.2 Clean up any duplicate stats files

## Phase 5: Temporary Directories Cleanup ✅ COMPLETED
- [x] 5.1 Review contents of `temp/` directory - was empty
- [x] 5.2 Review contents of `tmp/` directory - moved useful files to references/
- [x] 5.3 Review contents of `hidden/` directory - keep for stats scripts
- [x] 5.4 Review contents of `user-asked-content/` directory - keep for user content
- [x] 5.5 Remove empty `temp/` and `tmp/` directories

## Phase 6: Duplicate AI Backend Resolution ⚠️ SKIPPED
- [ ] 6.1 Analyze `src/AI/ai_backend/` contents
- [ ] 6.2 Merge or archive duplicate ai_backend
- ⚠️ SKIPPED - requires careful analysis of duplicate content

## Phase 7: Final Verification
- [ ] 7.1 Verify all moves completed
- [ ] 7.2 Update package.json if needed
- [ ] 7.3 Update import paths if needed
- [ ] 7.4 Test application still runs

---

## Status Summary
- Total Tasks: ~30
- Completed: 0
- Remaining: 30
- Current Phase: To Be Started

---

## Notes
- All changes are reversible via git
- Backups created before major moves
- Documentation updated after each phase

