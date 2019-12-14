module Pdf

using PDFIO,
      PDFIO.PD,
      PDFIO.Cos,
      PDFIO.Common

function withPdDoc(f::Function, filepath::AbstractString)
  doc = pdDocOpen(filepath)
  try
      f(doc)
  finally
      pdDocClose(doc)
  end
end

include("iter.jl")
include("pdwalk.jl")
include("show.jl")

export PDWalkObj,
       PDWalkParent,
       PDWalkChild,
       walk,
       postwalk,
       get_child,
       withPdDoc

#=
hierarchy


::CosObject

#TODO: Cos types

::PDDoc
    pages::PDPage[]

::PDPage
    contents::PDPageObjectGroup

::PDPageObject
::PageObject=Union{PDPageObject,CosObject}

::PDPageObjectGroup <: PDPageObject
    objs::PageObject[]

::PDPageElement{Op} <: PDPageObject
    op::Symbol
    operands::CosObject[]

::PDPageTextObject <: PDPageObject
    group::PDPageObjectGroup

::PDPageMarkedContent <: PDPageObject
    group::PDPageObjectGroup


::PDPageElement{:BT} = Begin Text Object
::PDPageElement{:ET} = End Text Object


::PDPageTextRun
    ss::?

    ->  PFDIO.get_TextBox(
            ss::Vector{Union{CosXString, CosLiteralString, CosFloat, CosInt}},
            pdfont::PDFont,
            tfs, tc, tw, th
        )
    ->  get_text(tr::PDPageTextRun) = begin
            evalContent!(tr.elem, state)
            tfs = get(state, :fontsize, 0f0)
            th  = get(state, :Tz, Float32)/100f0
            ts  = get(state, :Ts, Float32)
            tc  = get(state, :Tc, Float32)
            tw  = get(state, :Tw, Float32)
            tm  = get(state, :Tm, Matrix{Float32})
            ctm = get(state, :CTM, Matrix{Float32})
            trm = tm*ctm

            (fontname, font) = get(state, :font,
                                   (cn"", CosNull),
                                   Tuple{CosName, PDFont})

            heap = get(state, :text_layout, Vector{TextLayout})
            text, w, h = get_TextBox(tr.ss, font, tfs, tc, tw, th)
            return text
        end

=#
end
