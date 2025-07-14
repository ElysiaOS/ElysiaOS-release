import sys
import subprocess
import os
from PyQt6.QtWidgets import (
    QApplication, QWidget, QPushButton, QTextEdit, QVBoxLayout,
    QHBoxLayout, QLabel, QScrollArea, QFrame, QGraphicsDropShadowEffect
)
from PyQt6.QtCore import Qt, QTimer, QProcess
from PyQt6.QtGui import QPixmap, QColor, QTextCursor

ASSETS_PATH = os.path.join(os.path.dirname(os.path.abspath(__file__)), "..", "assets", "assets")
ASSETS_PATH = os.path.abspath(ASSETS_PATH)



def get_user_theme():
    return os.environ.get("GTK_THEME", "Adwaita")


class ElysiaUpdater(QWidget):
    def __init__(self):
        super().__init__()
        self.setWindowTitle("Elysia Updater")
        self.setFixedSize(1280, 720)
        self.setStyleSheet("background: transparent;")
        self.updates = []
        self.process = None
        self.update_buttons = []

        self.bg = QLabel(self)
        self.bg.setScaledContents(True)
        self.bg.lower()

        self.card = QFrame(self)
        self.card.setStyleSheet("QFrame { background-color: rgba(0, 0, 0, 0.3); border-radius: 26px; }")
        self.card.setGraphicsEffect(self.shadow())
        self.layout = QVBoxLayout(self.card)
        self.layout.setContentsMargins(30, 30, 30, 30)
        self.layout.setSpacing(20)

        self.output = QTextEdit()
        self.output.setReadOnly(True)
        self.output.setStyleSheet("""
            QTextEdit {
                background-color: rgba(255,255,255,0.05);
                color: white;
                font-size: 14px;
                font-family: Monospace;
                border-radius: 10px;
                padding: 10px;
            }
        """)
        self.layout.addWidget(self.output)

        self.scroll_area = QScrollArea()
        self.scroll_area.setStyleSheet("background: transparent;")
        self.scroll_area.setWidgetResizable(True)
        self.scroll_widget = QWidget()
        self.scroll_layout = QVBoxLayout(self.scroll_widget)
        self.scroll_area.setWidget(self.scroll_widget)
        self.layout.addWidget(self.scroll_area)
        self.scroll_area.hide()

        bottom_container = QWidget()
        self.bottom_row = QHBoxLayout(bottom_container)
        self.bottom_row.setContentsMargins(0, 0, 0, 0)
        self.bottom_row.setSpacing(10)

        info_frame = QFrame()
        info_frame.setStyleSheet("QFrame { background: transparent; }")
        info_layout = QHBoxLayout(info_frame)
        icon = QLabel()
        icon.setPixmap(QPixmap(os.path.join(ASSETS_PATH, "quest.png")).scaled(54, 54, Qt.AspectRatioMode.KeepAspectRatio, Qt.TransformationMode.SmoothTransformation))
        text = QLabel("Info")
        text.setStyleSheet("color: white; font-size: 16px; font-weight: bold;")
        info_layout.addWidget(icon)
        info_layout.addWidget(text)
        info_layout.setAlignment(Qt.AlignmentFlag.AlignLeft)

        self.bottom_row.addWidget(info_frame)
        self.bottom_row.addStretch()

        self.check_btn = QPushButton("CHECK FOR UPDATES")
        self.check_yay_btn = QPushButton("CHECK YAY UPDATES")
        self.cancel_btn = QPushButton("CLOSE")

        self.check_btn.clicked.connect(self.check_updates)
        self.check_yay_btn.clicked.connect(self.check_yay_updates)
        self.cancel_btn.clicked.connect(self.close)

        for btn in [self.check_yay_btn, self.check_btn, self.cancel_btn]:
            btn.setCursor(Qt.CursorShape.PointingHandCursor)
            btn.setStyleSheet(self.fancy_button_style(btn))
            btn.setFixedSize(200, 40)

        self.bottom_row.addWidget(self.check_yay_btn)
        self.bottom_row.addWidget(self.check_btn)
        self.bottom_row.addWidget(self.cancel_btn)
        self.layout.addWidget(bottom_container)
        self.bottom_container = bottom_container

        QTimer.singleShot(0, self.set_background_by_theme)

    def fancy_button_style(self, btn):
        if btn.text() == "CLOSE":
            bg = "#d2b48c"
            text_color = "#f0f0f0"
        else:
            bg = "#a87c4f"
            text_color = "#ffffff"
        return f"""
        QPushButton {{
            background-color: {bg};
            border: none;
            border-radius: 10px;
            color: {text_color};
            font-size: 13px;
            font-family: ElysiaOSNew;
            font-weight: bold;
            padding: 6px 12px;
            letter-spacing: 1px;
        }}
        QPushButton:hover {{
            background-color: #b88c5f;
        }}
        QPushButton:pressed {{
            background-color: #8c6239;
        }}
        """

    def shadow(self):
        shadow = QGraphicsDropShadowEffect()
        shadow.setBlurRadius(25)
        shadow.setColor(QColor(0, 0, 0, 180))
        shadow.setOffset(0, 10)
        return shadow

    def resizeEvent(self, event):
        self.bg.setGeometry(0, 0, self.width(), self.height())
        margin = 50
        self.card.setGeometry(margin, margin, self.width() - margin * 2, self.height() - margin * 2)

    def set_background_by_theme(self):
        try:
            theme = get_user_theme()
            print(f"Theme detected: {theme}")
            bg_file = "elysian-ui-hoc.png" if theme == "ElysiaOS-HoC" else "elysian-ui.png"
            self.bg.setPixmap(QPixmap(os.path.join(ASSETS_PATH, bg_file)))
        except Exception as e:
            print(f"Theme detection failed: {e}")
            self.bg.setPixmap(QPixmap(os.path.join(ASSETS_PATH, "elysian-ui.png")))

    def disable_buttons(self):
        self.check_btn.setEnabled(False)
        self.check_yay_btn.setEnabled(False)

    def enable_buttons(self):
        self.check_btn.setEnabled(True)
        self.check_yay_btn.setEnabled(True)

    def clear_scroll_layout(self):
        self.update_buttons.clear()
        while self.scroll_layout.count():
            child = self.scroll_layout.takeAt(0)
            if child.widget():
                child.widget().deleteLater()

    def enter_update_mode(self, message):
        self.output.setText(message)
        self.scroll_area.hide()
        self.bottom_container.hide()
        for btn in self.update_buttons:
            btn.hide()
        self.card.setStyleSheet("QFrame { background-color: rgba(0, 0, 0, 0.4); border-radius: 26px; }")

    def exit_update_mode(self):
        self.bottom_container.show()
        for btn in self.update_buttons:
            btn.show()
        self.card.setStyleSheet("QFrame { background-color: rgba(0, 0, 0, 0.3); border-radius: 26px; }")

    def check_updates(self):
        if not self.check_btn.isEnabled():
            return
        self.disable_buttons()
        self.clear_scroll_layout()
        self.output.clear()
        self.output.setText("🔃 Syncing before checking for updates...")
        self.sync_database(lambda: QTimer.singleShot(500, self.fetch_updates))

    def check_yay_updates(self):
        if not self.check_yay_btn.isEnabled():
            return
        self.disable_buttons()
        self.clear_scroll_layout()
        self.output.clear()
        self.output.setText("🔃 Checking for AUR (yay) updates...\n")
        try:
            result = subprocess.run(['yay', '-Qmu'], stdout=subprocess.PIPE, stderr=subprocess.PIPE, text=True)
            lines = result.stdout.strip().split('\n')
            lines = [line for line in lines if line.strip() and len(line.split()) >= 1 and not any(c in line for c in ['[', '{', '~'])]

            if not lines:
                self.output.setText("✅ All AUR packages are up to date.")
                self.enable_buttons()
                return

            self.updates = [line.split()[0] for line in lines]
            self.output.setText(f"🌟 {len(self.updates)} AUR updates found:\n")

            self.scroll_layout.setSpacing(10)
            for pkg in self.updates:
                row_widget = QWidget()
                row_layout = QHBoxLayout(row_widget)
                label = QLabel(pkg)
                label.setStyleSheet("color: white; font-size: 20px;")
                btn = QPushButton(f"Update Only {pkg}")
                btn.setStyleSheet(self.fancy_button_style(btn))
                btn.clicked.connect(lambda _, p=pkg: self.update_package_yay(p))
                row_layout.addWidget(label)
                row_layout.addStretch()
                row_layout.addWidget(btn)
                self.scroll_layout.addWidget(row_widget)
                self.update_buttons.append(btn)

            update_all_btn = QPushButton("Update All AUR")
            update_all_btn.setStyleSheet(self.fancy_button_style(update_all_btn))
            update_all_btn.setFixedHeight(40)
            update_all_btn.clicked.connect(self.update_all_yay)
            self.scroll_layout.addWidget(update_all_btn)
            self.update_buttons.append(update_all_btn)

            self.scroll_area.show()
        except Exception as e:
            self.output.setText(f"❌ Error: {str(e)}")
        self.enable_buttons()

    def sync_database(self, callback):
        self.output.append("🔃 Syncing package database...\n")
        sync_process = QProcess(self)
        sync_process.readyReadStandardOutput.connect(
            lambda: self.output.insertPlainText(sync_process.readAllStandardOutput().data().decode())
        )
        sync_process.readyReadStandardError.connect(
            lambda: self.output.insertPlainText(sync_process.readAllStandardError().data().decode())
        )
        sync_process.finished.connect(callback)
        sync_process.start('pkexec', ['pacman', '-Sy', '--noconfirm'])

    def fetch_updates(self):
        self.clear_scroll_layout()
        try:
            result = subprocess.run(['checkupdates'], stdout=subprocess.PIPE, stderr=subprocess.PIPE, text=True)
            lines = result.stdout.strip().split('\n')
            if not lines or lines == ['']:
                self.output.setText("✅ System is up to date.")
                self.enable_buttons()
                return

            self.updates = [line.split()[0] for line in lines]
            self.output.setText(f"🔧 {len(self.updates)} updates found:\n")

            self.scroll_layout.setSpacing(10)
            for pkg in self.updates:
                row_widget = QWidget()
                row_layout = QHBoxLayout(row_widget)
                label = QLabel(pkg)
                label.setStyleSheet("color: white; font-size: 20px;")
                btn = QPushButton(f"Update Only {pkg}")
                btn.setStyleSheet(self.fancy_button_style(btn))
                btn.clicked.connect(lambda _, p=pkg: self.update_package(p))
                row_layout.addWidget(label)
                row_layout.addStretch()
                row_layout.addWidget(btn)
                self.scroll_layout.addWidget(row_widget)
                self.update_buttons.append(btn)

            update_all_btn = QPushButton("Update All")
            update_all_btn.setStyleSheet(self.fancy_button_style(update_all_btn))
            update_all_btn.setFixedHeight(40)
            update_all_btn.clicked.connect(self.update_all)
            self.scroll_layout.addWidget(update_all_btn)
            self.update_buttons.append(update_all_btn)

            self.scroll_area.show()
        except Exception as e:
            self.output.setText(f"❌ Error: {str(e)}")
        self.enable_buttons()

    def update_package(self, pkg):
        self.enter_update_mode(f"⏳ Updating {pkg}...\n")
        self.sync_database(lambda: self.run_update(['pkexec', 'pacman', '-S', '--noconfirm', pkg]))

    def update_package_yay(self, pkg):
        self.enter_update_mode(f"⏳ Updating AUR package {pkg}...\n")
        self.run_update(['yay', '-S', '--noconfirm', pkg])

    def update_all(self):
        self.enter_update_mode("⏳ Updating all packages...\n")
        self.run_update(['pkexec', 'pacman', '-Syu', '--noconfirm'])

    def update_all_yay(self):
        self.enter_update_mode("⏳ Updating all AUR packages...\n")
        self.run_update(['yay', '-Sua', '--noconfirm'])

    def run_update(self, cmd):
        self.output.clear()
        if self.process:
            try:
                self.process.readyReadStandardOutput.disconnect(self.print_output)
                self.process.finished.disconnect(self.update_finished)
            except Exception:
                pass
            self.process.kill()
            self.process.deleteLater()

        self.process = QProcess(self)
        self.process.setProcessChannelMode(QProcess.ProcessChannelMode.MergedChannels)
        self.process.readyReadStandardOutput.connect(self.print_output)
        self.process.finished.connect(self.update_finished)
        self.process.start(cmd[0], cmd[1:])

    def print_output(self):
        output = self.process.readAllStandardOutput().data().decode()
        if output:
            self.output.moveCursor(QTextCursor.MoveOperation.End)
            self.output.insertPlainText(output)

    def update_finished(self):
        self.output.append("\n✅ Update finished!\nReturning to menu...")
        self.exit_update_mode()
        QTimer.singleShot(2000, self.reset_to_main_menu)

    def reset_to_main_menu(self):
        self.output.clear()
        self.clear_scroll_layout()
        self.bottom_container.show()
        self.enable_buttons()


if __name__ == "__main__":
    app = QApplication(sys.argv)
    window = ElysiaUpdater()
    window.show()
    sys.exit(app.exec())
