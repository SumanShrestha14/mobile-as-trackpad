"""OS input adapter implementation."""

from __future__ import annotations

import logging


class OSInputAdapter:
    """Maps protocol commands to host OS input actions."""

    def __init__(self, *, dry_run: bool = False) -> None:
        self._dry_run = dry_run
        self._log = logging.getLogger(__name__)
        self._backend = None

        if not dry_run:
            try:
                import pyautogui  # type: ignore

                self._backend = pyautogui
            except Exception as exc:  # pragma: no cover - backend may fail in CI/headless
                self._log.warning("Falling back to dry-run mode: %s", exc)
                self._dry_run = True

    def move(self, dx: float, dy: float) -> None:
        if self._dry_run:
            self._log.debug("DRY_RUN move dx=%s dy=%s", dx, dy)
            return
        assert self._backend is not None
        self._backend.moveRel(dx, dy, duration=0)

    def tap(self, button: str = "left", clicks: int = 1) -> None:
        if self._dry_run:
            self._log.debug("DRY_RUN tap button=%s clicks=%s", button, clicks)
            return
        assert self._backend is not None
        self._backend.click(button=button, clicks=clicks)

    def down(self, button: str = "left") -> None:
        if self._dry_run:
            self._log.debug("DRY_RUN down button=%s", button)
            return
        assert self._backend is not None
        self._backend.mouseDown(button=button)

    def up(self, button: str = "left") -> None:
        if self._dry_run:
            self._log.debug("DRY_RUN up button=%s", button)
            return
        assert self._backend is not None
        self._backend.mouseUp(button=button)

    def scroll(self, amount: int) -> None:
        if self._dry_run:
            self._log.debug("DRY_RUN scroll amount=%s", amount)
            return
        assert self._backend is not None
        self._backend.scroll(amount)
