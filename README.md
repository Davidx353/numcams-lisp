# Camera Numbering AutoLISP Script

This AutoLISP routine helps automate numbering and labeling of camera blocks along a specified polyline (such as a fence or boundary) in AutoCAD. The user selects the first camera block to start numbering from, then selects all camera blocks and the polyline that represents the fence or path. The script calculates the order of cameras based on their position along the polyline, starting at the selected first camera and continuing sequentially.

Each camera block is labeled with an MText entity showing a customizable prefix and number, placed just to the left of the block insertion point.

## Usage

- Load the `.lsp` file into AutoCAD.
- Run the command `NUMCAMS`.
- Follow prompts to select cameras, polyline, prefix, and start number.

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
