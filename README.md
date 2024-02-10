# Auto-Slice-Atlas
Auto divides an image into frames using the transperency of the image to determine the frames.

[Atlas Cutter.webm](https://github.com/newold3/Auto-Slice-Atlas/assets/52895466/5b486430-0b2e-4fe3-9fd0-b0f2b4b5a73f)


# Install

- Move the folder "AtlasCutter" to your addon folder.
- Enable Plugin in Project / Config / Plugin / Atlas Cutter.
- You can now create CutterSprite2D, CutterTextureRect and CutterTextureButton nodes.

# Use

- Add a node CutterSprite2D, CutterTextureRect or CutterTextureButton.
- Drag and drop any texture into Main texture in the inspector (If the texture has several frames, they should be separated from each other for the cutter to detect them, otherwise it will detect them all as a single frame).
- Now you can display the desired frame by changing the "Current Frame" value in the inspector.
- * Note #1: CutterTextureButton can handle 5 textures. change the target texture in the inspector in "Target" to add the texture to the corresponding state of the button (normal, disabled, pressed, hover...).
  * Note #2: Use "Epsilon" in the inspector if the generated frames do not correspond to the expected ones. A value lower than the default value (1) could correct the creation of erroneous frames.
