{ buildPythonApplication
, velbustcp-blinker
, setuptools
, pyserial
, pyserial-asyncio-fast
, lib
, src
}: buildPythonApplication rec {
    inherit src;
    pname = "python-velbustcp";
    version = src.shortRev;
    format = "pyproject";
    buildInputs = [ setuptools ];
    propagatedBuildInputs = [ pyserial pyserial-asyncio-fast velbustcp-blinker ];
    meta = with lib; {
        homepage = "https://github.com/velbus/python-velbustcp";
        description = "Python application that bridges a Velbus installation with TCP";
        license = licenses.mit;
    };
}
