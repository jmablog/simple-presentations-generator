A series of templates for [Quarto](https://quarto.org/) to convert a single Markdown input into beautiful and simple Powerpoint, HTML, [RevealJS](https://revealjs.com/), and PDF presentations.

## Features

All of the presentation features available in Quarto can be used with these templates - see [this Quarto guide](https://quarto.org/docs/presentations/powerpoint.html) for more.

## Usage

- Install [Quarto](https://quarto.org/docs/getting-started/installation.html). Some additional dependencies may be required, for example, a [TeX installation](https://quarto.org/docs/getting-started/installation.html#tex) if you don't have one already, or Python/R if you intend to use them in your materials - see the Quarto installation page for full details. You might also want to grab [Open Sans](https://www.opensans.com/) for the PDF font, or else change it to one you already have in `_quarto.yml`.
- Clone or download this repo to your local machine.
- Write your materials as required - either as plain Markdown files (`.md`) or using Quarto's own file type (`.qmd`). These can be in the base project directory, or stored in sub-folders to more conveniently keep related material together (e.g. image files to be included), in which case the directory structure used will be echoed in the output directory. For more details on how to write presentations in Markdown, see [this Quarto guide](https://quarto.org/docs/presentations/powerpoint.html).
- From a terminal at the base project directory, simply run `quarto render`. Your output files should appear in the `_PRESENTATIONS` folder.
- Turn formats on or off by commenting out or deleting their entries under the `format` field in `_quarto.yml`.

## Post-render script

If (like me) you want to store your outputs alongside your inputs rather than in their own sub-directory (`_PRESENTATIONS`), then a post-render step can be added to move all the output files back into their source directories and then cleanup the output directory. This script is written in Typescript to run in Deno, which is included with Quarto, so no extra dependencies are required. It reads the output directory you are using from the `_quarto.yml` file, cycles through all the files and files in sub-directories (to one level deep) in that output directory, and moves them back alongside their source input files. 

In `_quarto.yml`, simply uncomment the line `post-render: _resources/scripts/return-to-source.ts` to use this script.

## RevealJS file output

As both RevealJS and the regular HTML processing in Quarto produce `.html` files, `_quarto.yml` has RevealJS setup to use `.htm` as a file extension instead. It should still work fine as a HTML file, but you can rename it to something else if you wish.

Alternatively, the post render script above also automatically renames the RevealJS output to append `-RJS` to the filename, and then reverts it to a standard HTML file.

## Changing Powerpoint style

In `_quarto.yml`, there is a section under `format` for Powerpoint that determines the Powerpoint theme used as a reference document:

```
pptx:
  reference-doc: _resources/templates/pptx/cosmic-latte.pptx
```

Change this to one of the other themes available in `_resources/templates/pptx`. Options are `cosmic-latte`, `classy`, `dark-mode`, and `nord-theme`.

## Further customisation

The `_quarto.yml` file contains most of the other configuration options - in particular, a lot of the PDF output formatting such as fonts. These are all either [Quarto project options](https://quarto.org/docs/reference/projects/core.html) or [Pandoc options](https://pandoc.org/MANUAL.html#options) - add or change these as desired.

For further customisation, you can simply make changes to the templates themselves in `_resources/templates`. They are named for each output format. If you know CSS / LaTeX / Powerpoint styles, go nuts!

## Credit

The html template used is adapted from the [GitHub Pandoc HTML5 template](https://htmlpreview.github.io/?https://github.com/tajmone/pandoc-goodies/blob/master/templates/html5/github/GitHub-Template-Preview.html) from the [pandoc-goodies](https://github.com/tajmone/pandoc-goodies) repository by Tristano Ajmone.

Pandoc lua filters are inspired and adapted from examples given in the Pandoc [lua filters GitHub repo](https://github.com/pandoc/lua-filters).