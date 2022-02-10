import { parse } from "https://deno.land/std/encoding/yaml.ts";
import { extname } from "https://deno.land/std/path/mod.ts";

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

			if (extname(dir.name) === ".htm") {
				const file = dir.name;
				const filename_length = file.length - 4;
				const new_file = file.substring(0, filename_length) + '-RJS.html';
				Deno.renameSync(`${output_path}/${dir.name}`, `${output_path}/${new_file}`);
				Deno.copyFileSync(`${output_path}/${new_file}`, `./${new_file}`);
			} else {
			Deno.copyFileSync(`${output_path}/${dir.name}`, `./${dir.name}`);
			}
		} catch (e) {
			console.log(e);
		}
	}

	if (dir.isDirectory) {
		const sub_path = `${output_path}/${dir.name}`
		for (const sub of Deno.readDirSync(sub_path)) {
			try {
				if (sub.isFile) {
					if (extname(sub.name) === ".htm") {
						const file = sub.name;
						const filename_length = file.length - 4;
						const new_file = file.substring(0, filename_length) + '-RJS.html';
						Deno.renameSync(`${sub_path}/${sub.name}`, `${sub_path}/${new_file}`);
						const dest_dir = `./${dir.name}`
						Deno.copyFileSync(`${sub_path}/${new_file}`, `${dest_dir}/${new_file}`);
						} else {
						const dest_dir = `./${dir.name}`
						Deno.copyFileSync(`${sub_path}/${sub.name}`, `${dest_dir}/${sub.name}`);
					}
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
