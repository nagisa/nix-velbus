{ buildPythonPackage
, typing-extensions
, setuptools
, lib
}: buildPythonPackage rec {
        pname = "blinker";
        version = "1.6.1";
        src = fetchPypi {
            inherit pname version;
            hash = "sha256-Ld+iI0g86PJOzScj4OJ81DiO8ZvvHXawmj2ukwM9sjE=";
        };
        format = "pyproject";
        buildInputs = [ setuptools ];
        propagatedBuildInputs = [ typing-extensions ];
        pythonImportsCheck = [ "blinker" ];
        meta = with lib; {
            homepage = "https://pythonhosted.org/blinker/";
            description = "Fast, simple object-to-object and broadcast signaling";
            license = licenses.mit;
            maintainers = with maintainers; [ ];
        };
    }


