import os
import re
import subprocess
from pathlib import Path


def run_git(*args: str) -> str:
    return subprocess.check_output(["git", *args], text=True, encoding="utf-8").strip()


def release_tag() -> str:
    return os.environ.get("RELEASE_TAG", "").strip() or run_git("describe", "--tags", "--exact-match")


def previous_tag(current_tag: str) -> str:
    tags = run_git("tag", "--list", "v*", "--sort=-v:refname").splitlines()
    tags = [tag.strip() for tag in tags if tag.strip() and tag.strip() != current_tag]
    return tags[0] if tags else ""


def commit_subjects(current_tag: str, previous: str) -> list[str]:
    revision_range = f"{previous}..{current_tag}" if previous else current_tag
    output = run_git("log", "--pretty=%s", revision_range)
    subjects = []
    for line in output.splitlines():
        subject = line.strip()
        if not subject:
            continue
        if re.match(r"^chore: release v\d+\.\d+\.\d+$", subject):
            continue
        if re.match(r"^chore\(发布\):", subject):
            continue
        subjects.append(subject)
    return subjects


def humanize(subject: str) -> str:
    mappings = [
        (r"^feat\(应用更新\):", "新增应用更新能力："),
        (r"^feat\(播放页\):", "播放页增强："),
        (r"^fix\(首页搜索\):", "首页与搜索修复："),
        (r"^fix\(书籍详情\):", "书籍详情修复："),
        (r"^fix:", "修复："),
        (r"^feat:", "新增："),
        (r"^refactor:", "重构："),
        (r"^chore:", "调整："),
    ]
    for pattern, prefix in mappings:
        if re.match(pattern, subject):
            return re.sub(pattern, prefix, subject).strip()
    return subject


def fallback_notes(current_tag: str) -> list[str]:
    if current_tag == "v1.0.8":
        return [
            "重构首页、搜索、书籍详情和播放页 UI，整体贴近新版移动端原型。",
            "本地持久化迁移到 Drift/SQLite，统一保存书架、搜索历史、播放历史、章节进度、下载缓存和 Cookie。",
            "书籍详情页支持真实章节进度展示，包括未播放、播放至百分比、已播和正在播放状态。",
            "新增单集下载缓存，播放器会优先使用本地缓存音频。",
            "完善书架、我的、分享、睡眠定时和迷你播放器入口。",
        ]
    return ["优化体验并修复已知问题。"]


def main() -> None:
    current = release_tag()
    previous = previous_tag(current)
    subjects = commit_subjects(current, previous)
    generic_subjects = {"refactor: UI重构", "refactor: ui重构", "refactor: UI 重构"}
    if not subjects or all(subject in generic_subjects for subject in subjects):
        notes = fallback_notes(current)
    else:
        notes = [humanize(subject) for subject in subjects]

    lines = [
        f"# 有声听书 {current}",
        "",
        "## 本次更新",
    ]
    lines.extend(f"- {note}" for note in notes)
    lines.extend(
        [
            "",
            "## 安装说明",
            "- 普通 Android 用户请下载 APK 文件安装。",
            "- AAB 文件用于应用商店发布，不适合直接安装。",
        ]
    )
    if previous:
        lines.extend(
            [
                "",
                "## 完整变更",
                f"https://github.com/wangermaizi/audio_book/compare/{previous}...{current}",
            ]
        )

    Path("release_notes.md").write_text("\n".join(lines) + "\n", encoding="utf-8")


if __name__ == "__main__":
    main()
