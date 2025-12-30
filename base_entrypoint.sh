#!/usr/bin/env bash
set -e

# Add password to x11vnc options
if [ -n "${VNC_PASSWORD}" ]; then
    X11VNC_OPTIONS="${X11VNC_OPTIONS} -passwd '${VNC_PASSWORD}'"
fi

# Print current VNC info
echo "Current VNC info:"
echo "-----------------"
echo "VNC Screen: ${VNC_SCREEN}"
echo "VNC Display: ${VNC_DISPLAY}"
echo "VNC resolution: ${VNC_RESOLUTION}"
echo "VNC password: ${VNC_PASSWORD}"
echo "VNC Port: ${VNC_PORT}"
echo "NOVNC Websockify Port: ${NOVNC_WEBSOCKIFY_PORT}"

# Print other container's info
echo "-----------------"
echo "Other Info:"
echo "-----------------"
echo "Lang: ${LANG}"
echo "LC All: ${LC_ALL}"
echo "Customize active: ${CUSTOMIZE}"
echo "Custom entrypoints dir: ${CUSTOM_ENTRYPOINTS_DIR}"
echo "Autostart browser: ${AUTO_START_BROWSER}"

# Handle Dark Mode logic
if [ "${DARK_MODE}" = "true" ]; then
    export GTK_THEME=Adwaita:dark
    BROWSER_OPTIONS="${BROWSER_OPTIONS} --force-dark-mode"
    export XTERM_OPTIONS="${XTERM_OPTIONS} -bg black -fg white"
    mkdir -p /root/.fluxbox/styles
    
    # Select base style (Debian or Alpine fallback)
    STYLE_SOURCE="/usr/share/fluxbox/styles/debian-dark"
    if [ ! -e "$STYLE_SOURCE" ]; then
        STYLE_SOURCE="/usr/share/fluxbox/styles/BlueNight"
    fi

    # Create CustomDark style
    if [ -e "$STYLE_SOURCE" ]; then
        cp "$STYLE_SOURCE" /root/.fluxbox/styles/CustomDark
        # Remove existing rootCommand from the style to prevent overrides
        sed -i '/rootCommand/d' /root/.fluxbox/styles/CustomDark
        
        # Force charcoal background by modifying the style properties directly
        # This overrides the default "teal" (rgb:6A/9A/AF) from BlueNight
        sed -i 's/^background.color:.*/background.color: #333333/' /root/.fluxbox/styles/CustomDark
        
        # Ensure it is set to flat so the color applies
        if grep -q "background:" /root/.fluxbox/styles/CustomDark; then
             sed -i 's/^background:.*/background: flat/' /root/.fluxbox/styles/CustomDark
        else
             echo "background: flat" >> /root/.fluxbox/styles/CustomDark
        fi

        echo "session.styleFile: /root/.fluxbox/styles/CustomDark" >> /root/.fluxbox/init
    else
         # Fallback if no known style exists
        echo "session.screen0.rootCommand: fbsetroot -solid '#333333'" >> /root/.fluxbox/init
    fi
fi

echo "Homepage website URL: ${STARTING_WEBSITE_URL}"
echo "Autostart xterm: ${AUTO_START_XTERM}"
echo "-----------------"

# Start Supervisor
exec supervisord -c /etc/supervisor.d/supervisord.conf
