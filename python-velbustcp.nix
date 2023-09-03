{ buildPythonApplication
, velbustcp-blinker
, setuptools
, pyserial
, lib
, src
}: buildPythonApplication rec {
    inherit src;
    pname = "python-velbustcp";
    version = src.shortRev;
    format = "pyproject";
    buildInputs = [ setuptools ];
    propagatedBuildInputs = [ pyserial velbustcp-blinker ];
    meta = with lib; {
        homepage = "https://github.com/velbus/python-velbustcp";
        description = "Python application that bridges a Velbus installation with TCP";
        license = licenses.unfree; # The license is not specified => defaults to unfree.
    };
}
