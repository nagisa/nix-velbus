{ buildPythonApplication
, velbustcp-blinker
, setuptools
, lib
, src
}: buildPythonApplication rec {
        pname = "python-velbustcp";
        version = inputs.python-velbustcp.shortRev;
        format = "pyproject";
        src = inputs.python-velbustcp;
        buildInputs = [ setuptools ];
        propagatedBuildInputs = [ pyserial python-velbustcp-blinker ];
        meta = with lib; {
            homepage = "https://github.com/velbus/python-velbustcp";
            description = "Python application that bridges a Velbus installation with TCP";
            license = licenses.unfree; # The license is not specified => defaults to unfree.
        };
    };
