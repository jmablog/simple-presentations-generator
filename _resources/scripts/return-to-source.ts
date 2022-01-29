import { parse } from "https://deno.land/std/encoding/yaml.ts";

// declare type for Quarto options read in from yaml
type Quarto_Opts = {
	project: {
		"output-dir": string;
	}
}

// read in the yaml file and set output dir to match that used in the Quarto project
const quarto: Quarto_Opts = parse(Deno.readTextFileSync("_quarto.yml")) as Quarto_Opts;
const output_path = quarto.project["output-dir"];

// loop through all files in the output directory and move them back to their source directory
// only works for single nested directories
for (const dir of Deno.readDirSync(output_path)) {
	if (dir.isFile) {
		try {
			Deno.copyFileSync(`${output_path}/${dir.name}`, `./${dir.name}`);
		} catch (e) {
			console.log(e);
		}
	}

	if (dir.isDirectory) {
		const sub_path = `${output_path}/${dir.name}`
		for (const sub of Deno.readDirSync(sub_path)) {
			try {
				if (sub.isFile) {
					const dest_dir = `./${dir.name}`
					Deno.copyFileSync(`${sub_path}/${sub.name}`, `${dest_dir}/${sub.name}`);
				}
			} catch (e) {
				console.log(e);
			}
		}
	}
}	

// remove the output directory
try {
	Deno.removeSync(output_path, { recursive: true });
} catch (e) {
	console.log(e);
}
