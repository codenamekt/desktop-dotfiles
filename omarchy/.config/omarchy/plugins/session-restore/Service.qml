import QtQuick
import Quickshell
import Quickshell.Io

// Session Restore — macOS-style "reopen windows on login" for Hyprland.
//
// On login (shell start) it relaunches the windows saved from the previous
// session on their original workspaces, then keeps a snapshot daemon running
// (every 60 s) so even crash/power-button exits come back at most a minute
// stale. Disabling this plugin (`omarchy plugin disable session-restore`)
// unloads the service and kills the daemon.
Item {
  id: root

  readonly property string home: Quickshell.env("HOME")
  readonly property string pluginDir: home + "/.config/omarchy/plugins/session-restore"
  readonly property string script: pluginDir + "/hypr-session-restore"
  readonly property string stateDir: home + "/.local/state/hypr-session-restore"
  readonly property string pidFile: stateDir + "/daemon.pid"
  readonly property int restoreDelayMs: 2000

  function log(message) {
    console.log("session-restore " + new Date().toISOString() + " " + message)
  }

  function run(process, label, command) {
    if (process.running) {
      log("skip " + label + " (already running)")
      return
    }
    log("start " + label + ": " + command)
    process.command = ["bash", "-lc", command]
    process.running = true
  }

  function ensureDaemon() {
    // pidfile guard: shell restarts must not stack daemons. The wrapper
    // self-terminates when this plugin is disabled (checks shell.json every
    // 20 s), so disable/enable fully controls the daemon.
    run(daemonProcess, "daemon",
      "mkdir -p '" + root.stateDir + "'; "
      + "if [[ -f '" + root.pidFile + "' ]] && kill -0 $(cat '" + root.pidFile + "') 2>/dev/null; then exit 0; fi; "
      + "setsid '" + root.pluginDir + "/session-restore-daemon' </dev/null >/dev/null 2>&1 &")
  }

  function stopDaemon() {
    // Best-effort immediate stop; the wrapper self-exit covers the rest.
    run(killProcess, "daemon-stop",
      "if [[ -f '" + root.pidFile + "' ]]; then kill $(cat '" + root.pidFile + "') 2>/dev/null; fi")
  }

  Component.onCompleted: {
    log("service-ready; restore + daemon enabled")
    // Restore the previous session once the compositor has settled. Restore
    // aborts by design when a session is already populated (>3 windows), so
    // shell restarts mid-session are safe.
    run(restoreProcess, "restore", "sleep 2 && '" + root.script + "' restore")
    ensureDaemon()
  }

  Component.onDestruction: {
    log("service-unload; stopping daemon")
    stopDaemon()
  }

  Process {
    id: restoreProcess
    onExited: function(exitCode, exitStatus) { root.log("restore exited code=" + exitCode + " status=" + exitStatus) }
  }
  Process {
    id: daemonProcess
    onExited: function(exitCode, exitStatus) { root.log("daemon launcher exited code=" + exitCode + " status=" + exitStatus) }
  }
  Process {
    id: saveProcess
    onExited: function(exitCode, exitStatus) { root.log("save exited code=" + exitCode + " status=" + exitStatus) }
  }
  Process {
    id: killProcess
    onExited: function(exitCode, exitStatus) { root.log("daemon-stop exited code=" + exitCode + " status=" + exitStatus) }
  }

  IpcHandler {
    target: "session-restore"

    function status(): string {
      return JSON.stringify({
        pluginDir: root.pluginDir,
        stateDir: root.stateDir,
        restoreRunning: restoreProcess.running,
        daemonLauncherRunning: daemonProcess.running
      })
    }

    function save(): string {
      root.run(saveProcess, "save", "'" + root.script + "' save")
      return "ok"
    }
  }
}
