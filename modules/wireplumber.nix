# WirePlumber disables automatic profile/port selection for every ALSA
# device by default (monitors/alsa.lua: applyDefaultDeviceProperties), so a
# freshly-plugged device sits on its lowest-priority profile ("off") until
# something picks one. For most hardware the last-used profile is then
# remembered in ~/.local/state/wireplumber/default-profile and silently
# restored next time -- but that cache can be wiped (new user, fresh
# profile, state dir cleared), at which point the Scarlett would vanish
# from the sound settings again with no obvious error. This rule pins the
# profile selection at the WirePlumber config level instead of relying on
# that cache, matched by USB vendor/product id (Focusrite Scarlett 2i2).
{ ... }:
{
  xdg.configFile."wireplumber/wireplumber.conf.d/51-scarlett-2i2.conf".text = ''
    monitor.alsa.rules = [
      {
        matches = [
          {
            device.vendor.id = "0x1235"
            device.product.id = "0x8202"
          }
        ]
        actions = {
          update-props = {
            api.acp.auto-profile = true
            api.acp.auto-port = true
          }
        }
      }
    ]
  '';
}
