{
  lib,
  fetchFromGitHub,
  python3,
}:

python3.pkgs.buildPythonApplication {
  pname = "graphqlmap";
  version = "unstable-2022-01-17";
  format = "pyproject";

  src = fetchFromGitHub {
    owner = "swisskyrepo";
    repo = "GraphQLmap";
    rev = "98997bd7cf647aac7378b72913241060464749b1";
    hash = "sha256-lGnhNwtDc8KoPlwJ1p2FYq0NQ8PhSR3HgtluU7uxa/c=";
  };

  build-system = with python3.pkgs; [
    setuptools
  ];

  dependencies = with python3.pkgs; [
    requests
  ];

  # Tests are not available
  doCheck = false;

  pythonImportsCheck = [
    "graphqlmap"
  ];

  meta = with lib; {
    description = "Tool to interact with a GraphQL endpoint";
    mainProgram = "graphqlmap";
    homepage = "https://github.com/swisskyrepo/GraphQLmap";
    license = licenses.mit;
    maintainers = with maintainers; [ fab ];
  };
}
