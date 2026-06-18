{ pkgs, ... }:
{
  programs.yazi = {
    enable = true;
    settings = {
      mgr.show_hidden = true;
      plugin.prepend_previewers = [
        {
          url = "*.csv";
          run = "rich-preview";
        }
        {
          url = "*.md";
          run = "rich-preview";
        }
        {
          url = "*.rst";
          run = "rich-preview";
        }
        {
          url = "*.ipynb";
          run = "rich-preview";
        }
        {
          url = "*.json";
          run = "rich-preview";
        }
      ];
    };
    plugins = with pkgs.yaziPlugins; {
      smart-enter = smart-enter;
      rich-preview = rich-preview;
    };
    #? https://github.com/sxyazi/yazi/tree/shipped/yazi-config/preset
    keymap = {
      mgr = {
        prepend_keymap = [
          {
            on = "<F2>";
            run = "rename";
            desc = "Rename file or folder";
          }
          #? https://github.com/sxyazi/yazi/issues/1758#issuecomment-2407103834
          {
            on = "<Enter>";
            run = "plugin --sync smart-enter";
            desc = "Enter the child directory, or open the file";
          }
        ];
      };
    };
    #? https://github.com/sxyazi/yazi/blob/157156b5b8f36db15b2ba425c7d15589039a9e1e/yazi-plugin/preset/components/linemode.lua#L25
    initLua = /* lua */ ''
      function strip_date_year(time_to_format)
        local time = math.floor(time_to_format or 0)
        if time == 0 then
          return ""
        elseif os.date("%Y", time) == os.date("%Y") then
          return os.date("%m-%d %H:%M", time)
        else
          return os.date("%Y-%m-%d", time)
        end
      end
      function Linemode:btime()
        return strip_date_year(self._file.cha.btime)
      end
      function Linemode:mtime()
        return strip_date_year(self._file.cha.mtime)
      end
    '';
  };
}
