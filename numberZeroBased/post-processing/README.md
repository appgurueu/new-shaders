#Post-processing shaders for numberZero's Minetest fork.
The post-processing shaders found here are based on numberZero's work and underlay his license.
Link : https://github.com/numberZero/minetest/blob/feab8c526d4feff1afd92eb451b67ca8fc8c0be1/client/shaders/postprocessing/
If you want to test the new post-processing :
- compile numberZero's minetest fork with post-processing
- replace opengl_fragment.glsl in client/shaders/post-processing with my version.
- you may also replace opengl_vertex.glsl, but this is not necessary.
Current features : 
- focus blur
- edge darkening(kinda cheap ambient occlusion)
