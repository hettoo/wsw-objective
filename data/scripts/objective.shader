models/objective/constructor_boxes {
    nopicmip

    {
        map models/objective/constructor_boxes.tga
    }
}

models/objective/constructor_base {
    nopicmip
    cull front

    {
        map models/objective/constructor_base.tga
        rgbGen entity
    }

    if textureCubeMap
    {
        shadecubemap env/cell
        blendFunc filter
    }
    endif

    if ! textureCubeMap
    {
        map gfx/colors/celshade.tga
        blendfunc filter
        tcGen environment
    }
    endif
}

models/objective/constructor_holo {
    nopicmip
    cull none
    deformVertexes wave 20 noise 0.5 0.6 0 1.6

    {
        map models/objects/flag/flag_holo.tga
        blendFunc blend
        alphaGen const 0.6
        tcMod scroll 0.8 0.8
        depthWrite
    }

    {
        map models/objects/flag/flag_holo.tga
        blendFunc blend
        alphaGen const 0.4
        tcMod scroll 0.4 0.4
    }
}

textures/hettoo/objective/tv
{
    qer_editorimage textures/hettoo/objective/tv.tga
    surfaceparm playerclip
    surfaceparm nolightmap
    portal
    {
        map textures/hettoo/objective/tv.tga
        blendFunc GL_ONE GL_ONE_MINUS_SRC_ALPHA
        depthWrite
        alphaGen portal 2048
    }
}
