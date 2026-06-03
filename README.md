# Doxtr Documentation Runtime Environment

This container image contains a Sphinx documentation toolchain with support for

* **Full** [TeX Live](https://www.tug.org/texlive/) LaTeX installation
* [Markdown](https://daringfireball.net/projects/markdown/)
* [PlantUML](https://plantuml.com/)
* [Read the Docs Sphinx Theme](https://sphinx-rtd-theme.readthedocs.io/en/stable/)
* [BibTeX](http://www.bibtex.org/) support
* [reveal.js](https://revealjs.com/) support
* [Hovercraft!](https://hovercraft.readthedocs.io/en/latest/usage.html) support
* [Pelican](https://docs.getpelican.com/en/stable/index.html) with Markdown support
* [Hieroglyph](https://hieroglyph.readthedocs.io/en/latest/index.html) support
* [Jupyter Book](https://jupyterbook.org/intro.html) support
* [Excel Table Plus](https://pypi.org/project/sphinxcontrib-excel-table-plus/) support
* [Exceltable](https://pythonhosted.org/sphinxcontrib-exceltable/) support

and more.

# Build podman Image

In order for all of this to work, you need to have podman installed. You can [get it here](https://podman-desktop.io/).

You do not need to do this, but if you want to build the image yourself, you can do so with the following command.

```bash
$#> podman build -t doxtr/reactor .
```

You can build and push your own version of the image easily with:

```bash
#> export VERSION=0.0.1 && podman build -t doxtr/reactor:$VERSION . && podman push doxtr/reactor:$VERSION
```

# Building for Github release

Tag what you want to release

```bash
#> export VERSION=v0.0.1 && git tag $VERSION && git push origin $VERSION
```

Then hit 'Create a new release'on the right side of your github repository.

## Redoing the same version

Delete the tag, tag again, push release button

```bash
#> export VERSION=v1.0.0
#> git tag -d $VERSION && git push --delete origin $VERSION && git tag $VERSION && git push origin $VERSION
```

# Sphinx 

Use the following commands to interact with the sphinx container. The commands below show the raw `podman` command. You can however alias the command for convenience.

You can for example set an alias like this in your shell environment:

``` bash
$#> alias dx='podman run --rm -it -v $(pwd):/workspaces doxtr/reactor'
```

This will basically allow you to replace the long `podman run --rm -it -v $(pwd):/workspaces doxtr/reactor` command with the command or "alias" `dx`.

## Usage 

You can start an internal HTTP server by setting the HTTP_SERVER_PORT variable to the same value as one of the forwardPorts in your `.devcontainer/devcontainer.json` configuration file.

Make sure to pin the image to a version e.g. `"image": "doxtr/reactor:0.0.1",` so you're build won't break, if a new version is released (of course try the new version, once available).

```json
{
   "name": "My Documentation",
   "image": "doxtr/reactor",
   "forwardPorts": [
      8008
],
"containerEnv": {
    "HTTP_SERVER_PORT": "8008",
    "TZ": "Europe/Berlin"
},
"customizations": {
    "vscode": {
        "extensions": [
            "ms-python.python",
            "ms-toolsai.jupyter",
            "jebbs.plantuml",
            "trond-snekvik.simple-rst",
            "swyddfa.esbonio",
            "mechatroner.rainbow-csv",
            "useblocks.sphinx-needs-vscode"
        ],
        "settings": {
            "editor.suggest.snippetsPreventQuickSuggestions": true,
            "editor.suggest.matchOnWordStartOnly": true,
            "editor.renderWhitespace": "all",
            "python-envs.alwaysUseUv": true,
            "restructuredtext.builtDocumentationPath": "${workspaceRoot}/build/html",
            "restructuredtext.confPath": "${workspaceFolder}/source",
            "restructuredtext.updateOnTextChanged": "true",
            "restructuredtext.updateDelay": 1000,
            "python.pythonPath": "/opt/venv/bin/python",
            "editor.tabSize": 3,
            "[restructuredtext]": {
                "editor.tabSize": 3
            }
        }
    }
},
"workspaceMount": "source=${localWorkspaceFolder},target=/workspaces/docs,type=bind",
"workspaceFolder": "/workspaces/docs"
}
```

The container can then be started using the `rs` (for run/restart server) command alias. You can then reach the container web server from the host operating system using http://localhost:$HTTP_SERVER_PORT.

### Networking Tools Required

If your documentation project requires networking tools, such as e.g. the `ping` command, you need to give the `.devcontainer` additional capabilities.

You can do that with a `runArgs` block in the configuration like e.g.:

```json
"runArgs": [
    "--cap-add=NET_RAW", // used for the ping command in the tests
    // You can add other capabilities here if needed, like "--cap-add=NET_ADMIN"
    //"--cap-add=NET_ADMIN"
],
```

#### Snippet in context

```json
{
   "name": "My Documentation",
   "image": "doxtr/reactor:0.0.1",
   "forwardPorts": [
      8008
],
"containerEnv": {
    "HTTP_SERVER_PORT": "8008",
    "TZ": "Europe/Berlin"
},
"runArgs": [
    "--cap-add=NET_RAW", // used for the ping command in e.g. the tests
    // You can add other capabilities here if needed, like "--cap-add=NET_ADMIN"
    //"--cap-add=NET_ADMIN"
],
"customizations": {
    "vscode": {
        "extensions": [
            "ms-python.python",
            "ms-toolsai.jupyter",
            "jebbs.plantuml",
            "trond-snekvik.simple-rst",
            "swyddfa.esbonio",
            "mechatroner.rainbow-csv",
            "useblocks.sphinx-needs-vscode"
        ],
        "settings": {
            "editor.suggest.snippetsPreventQuickSuggestions": true,
            "editor.suggest.matchOnWordStartOnly": true,
            "editor.renderWhitespace": "all",
            "python-envs.alwaysUseUv": true,
            "restructuredtext.builtDocumentationPath": "${workspaceRoot}/build/html",
            "restructuredtext.confPath": "${workspaceFolder}/source",
            "restructuredtext.updateOnTextChanged": "true",
            "restructuredtext.updateDelay": 1000,
            "python.pythonPath": "/opt/venv/bin/python",
            "editor.tabSize": 3,
            "[restructuredtext]": {
                "editor.tabSize": 3
            }
        }
    }
},
"workspaceMount": "source=${localWorkspaceFolder},target=/workspaces/docs,type=bind",
"workspaceFolder": "/workspaces/docs"
}
```

## Sphinx on Windows

If you want to use this container on Windows, you need to slightly tweak the command line to read:

``` bash
$#> podman run --rm -it -v ${PWD}:/workspaces doxtr/reactor
```

## Create a new Sphinx document

If you want an interactive experience:

``` bash
$#> mkdir mydoc
$#> cd mydoc
$#> podman run --rm -it -v $(pwd):/workspaces doxtr/reactor sphinx-quickstart 
```

You you have used the `alias` command above, the `podman` command will look like:

``` bash
$#> dx sphinx-quickstart
```

Create a new document e.g. like so:

``` bash
$#> mkdir mydoc
$#> cd mydoc
$#> podman run --rm -it -v $(pwd):/workspaces doxtr/reactor sphinx-quickstart --sep -p "My Demo" -a "Doxtr Doc" -v "0.0.1" -r "0.0.1" -l "en" --suffix .rst --epub --master index --ext-intersphinx --ext-todo --makefile -m
```

## Compile a Sphinx document

You can generate your Sphinx document by executing the following command in the directory you created your document (in the above example `mydoc`).

The `clean` argument is not really necessary but might help in certain circumstanes, you could also just run `... make html`.

``` bash
$#> podman run --rm -it -v $(pwd):/workspaces doxtr/reactor make clean html
```

# Pelican Blog

You can create a new Pelican based blog with the `pelican-quickstart` command using it like:

``` bash
$#> podman run --rm -it -v $(pwd):/workspaces doxtr/reactor pelican-quickstart
```

If you want to preview your blog with the built in webserver on http://localhost:8000, use the following command:

``` bash
$#> podman run --rm -it -v $(pwd):/workspaces -p8000:8000 doxtr/reactor pelican -e BIND=0.0.0.0 --autoreload --listen
```

For further information see the [official documentation](https://workspaces.getpelican.com/en/stable/index.html).

## Using pelican themes

In order to use pelican themes, you have to make them accessible to the container runtime. I suggest mapping the path to `/pelican-themes` inside the container. That way you can configure the theme like `THEME="/pelican-themes/mnmlist"` for example.

You can find a lot of pelican themes [on Github](https://github.com/getpelican/pelican-themes)

I order to keep things separate, I'd suggest setting up, or cloning, the themes at the same level as your blog.

Say you created your blog in a folder called `tmp` you want to clone the themes repository into the `tmp` folder too, so it looks like:

```
tmp
├── blog
└── pelican-themes
```

You can clone the themes by executing the below command inside the `tmp` folder:

``` bash
$#> git clone --recursive https://github.com/getpelican/pelican-themes ./pelican-themes
```

The following command must be executed inside your `blog` folder. It will mount the `pelican-themes` folder into the container under `/pelican-themes` where you can reference it in your config.

``` bash
$#> podman run --rm -it -v $(pwd):/workspaces -v $(pwd)/../pelican-themes:/pelican-themes  -p8000:8000 doxtr/reactor pelican -e BIND=0.0.0.0 --autoreload --listen
```

# SASS Compiler

This is especially useful if you're planning to utilize CSS in your presentation. You can generate a CSS from a SCSS source file. You can learn all about that at the [Sass: Sass Basics](https://sass-lang.com/guide) site.

The image contains `pysassc` which is a SASS compiler, and the `pysass` wrapper ([pysass · PyPI](https://pypi.org/project/pysass/)) which allows you to watch the SASS files for changes and compile them automatically when they change.

# Hovercraft Presentations

You can find a description of all the bells and whistles of  `hovercraft` where it says [Hovercraft! - Merging convenience and cool!](https://hovercraft.readthedocs.io/en/latest/index.html)

## Compiling a hovercraft document

If you don't want to install all the tooling required to compile a hovercraft presentation, you can use the command below:

``` bash
$#> podman run --rm -it -v $(pwd):/workspaces doxtr/reactor hovercraft yourinput.rst output
```

## Using the built in web server

If you want to access your presentation through the web server built into `hovercraft`, you also need to expose or publish the port with the `podman` command.

You can run the server using the following command:

``` bash
$#> podman run --rm -it -p8000:8000 -v $(pwd):/workspaces doxtr/reactor hovercraft positions.rst
```

You can then access your presentation through a web browser by navigating to [localhost:8000](http://localhost:8000/).

# reveal.js Presentations

There seem to be multiple reveal.js implementations available at this point in time. I picked up on two of them.

A fairly new implementation of reveal.js presentations with Sphinx where a good starting point is probably the Github repository [attakei/sphinx-revealjs: Sphinx builder to revealjs presentations](https://github.com/attakei/sphinx-revealjs).

And one that is around for quite a bit but does not seem to be maintained any longer? which can be found in this Github repository [tell-k/sphinxjp.themes.revealjs: A sphinx theme for generate reveal.js presentation. #sphinxjp](https://github.com/tell-k/sphinxjp.themes.revealjs)

## Compiling a reveal.js presentation

Since there are two (or even more implementations) available at the moment I listed the two styles I know about below.

### >>> "attakei" style implementation

You can compile these presentations with:

``` bash
$#> podman run --rm -it -v $(pwd):/workspaces doxtr/reactor make revealjs
```

### >>> "tell-k" style implementation

You can compile these presentations with:

``` bash
$#> podman run --rm -it -v $(pwd):/workspaces doxtr/reactor make html
```

as you would compile any ordinary Sphinx document.

# Cleaning Up

If you're doing doing your documentation thing, you can clean up your system by executing:

```bash
$#> podman system prune -a
```