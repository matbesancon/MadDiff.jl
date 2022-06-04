"""
    HessianNull{T,RT} <: Hessian{T,RT} end
`Hessian` of linear expressions (e.g., Variable, Expression2{T, typeof(*), Int64, Variable{T,RT}} where T)
"""
struct HessianNull{T,RT} <: Hessian{T,RT} end

"""
    Hessian11{T,F,H1,H11} <: Hessian{T,RT}
`Hessian` of `Expression1`
"""
struct Hessian11{T, RT <: Ref{T},F,H1,H11} <: Hessian{T,RT}
    h1::H1
    h11::H11
    fref::RT
    ref::RT

    function Hessian11(e::Expression1{T,RT, F,E},d, indexer = nothing) where {T,RT, F,E}
        h1 = Hessian(e.e1,d.d1,indexer)
        h11= Hessian(d.d1,d.d1,indexer)
        return new{T,RT,F,typeof(h1),typeof(h11)}(h1,h11,ref(e.e1),ref(d))
    end
end

"""
    Hessian11F1{T,F,H1,H11,R} <: Hessian{T,RT}
`Hessian` of `Expression2` whose first argument is `<: Real`.
"""
struct Hessian11F1{T, RT <: Ref{T},F,H1,H11,R} <: Hessian{T,RT}
    a::R
    h1::H1
    h11::H11
    fref::RT
    ref::RT
    function Hessian11F1(e::Expression2{T,RT, F,E1,E2}, d,indexer = nothing) where {T,RT, F,E1 <: Real,E2} 
        h1 = Hessian(e.e2,d.d1,indexer)
        h11= Hessian(d.d1,d.d1,indexer)
        return new{T,RT,F,typeof(h1),typeof(h11),typeof(e.e1)}(e.e1,h1,h11,ref(e.e2),ref(d))
    end
 end

"""
    Hessian11F2{T,F,H1,H11,R} <: Hessian{T,RT}
`Hessian` of `Expression2` whose second argument is `<: Real`.
"""
struct Hessian11F2{T, RT <: Ref{T},F,H1,H11,R} <: Hessian{T,RT}
    a::R
    h1::H1
    h11::H11
    fref::RT
    ref::RT
    function Hessian11F2(e::Expression2{T,RT,F,E1,E2}, d,indexer = nothing) where {T,RT,F,E1,E2 <: Real}
        h1 = Hessian(e.e1,d.d1,indexer)
        h11= Hessian(d.d1,d.d1,indexer)
        return new{T,RT,F,typeof(h1),typeof(h11),typeof(e.e2)}(e.e2,h1,h11,ref(e.e1),ref(d))
    end
end

"""
    Hessian02{T,H11,H12,H21,H22} <: Hessian{T,RT}
`Hessian` of `
"""
struct Hessian02{T, RT <: Ref{T},H11,H12,H21,H22} <: Hessian{T,RT}
    h11::H11
    h12::H12
    h21::H21
    h22::H22
    ref11::RT
    ref12::RT
    ref21::RT
    ref22::RT
end
struct Hessian22{T, RT <: Ref{T},F,H1,H2,H11,H12,H21,H22} <: Hessian{T,RT}
    h1::H1
    h2::H2
    h11::H11
    h12::H12
    h21::H21
    h22::H22
    fref1::RT
    fref2::RT
    ref1::RT
    ref2::RT

    function Hessian22(e::Expression2{T,RT,F,E1,E2},d,indexer = nothing) where {T,RT,F,E1,E2}
        h1 = Hessian(e.e1,d.d1,indexer)
        h2 = Hessian(e.e2,d.d2,indexer)
        h11= Hessian(d.d1,d.d1,indexer)
        h12= Hessian(d.d1,d.d2,indexer)
        h21= Hessian(d.d2,d.d1,indexer)
        h22= Hessian(d.d2,d.d2,indexer)
        new{T,RT,F,typeof(h1),typeof(h2),typeof(h11),typeof(h12),typeof(h21),typeof(h22)}(h1,h2,h11,h12,h21,h22,ref(e.e1),ref(e.e2),ref1(d),ref2(d))
    end
end
struct HessianD00{T,RT} <: Hessian{T,RT}
    index1::Int
    index2::Int
    islower::Bool
end
struct HessianD00S{T,RT} <: Hessian{T,RT}
    index::Int
    islower::Bool
end
struct HessianD10{T, RT <: Ref{T},H <: Hessian{T,RT}} <: Hessian{T,RT}
    h::H
    ref::RT
end
struct HessianD20{T, RT <: Ref{T},H1 <: Hessian{T,RT},H2 <: Hessian{T,RT}} <: Hessian{T,RT}
    h1::H1
    h2::H2
    ref1::RT
    ref2::RT
end
struct HessianD11{T, RT <: Ref{T},H <: Hessian{T,RT}} <: Hessian{T,RT}
    h::H
    ref1::RT
    ref2::RT
end
struct HessianD21{T, RT <: Ref{T},H1,H2} <: Hessian{T,RT}
    h1::H1
    h2::H2
    ref::RT
    ref1::RT
    ref2::RT
end
struct Hessian22a{T, RT <: Ref{T},H1 <: Hessian{T,RT},H2 <: Hessian{T,RT}} <: Hessian{T,RT}
    h1::H1
    h2::H2
    ref1::RT
    ref2::RT
end
Hessian22a(::HN,::HN,ref1::RT,ref2::RT) where {T, RT <: Ref{T}, HN <: HessianNull{T,RT}} = HN()
Hessian22a(::HN,h2::H,ref1::RT,ref2::RT) where {T, RT <: Ref{T}, HN <: HessianNull{T,RT}, H<:Hessian{T,RT}} = Hessian11a(h2,ref2)
Hessian22a(h1::H,::HN,ref1::RT,ref2::RT) where {T, RT <: Ref{T}, HN <: HessianNull{T,RT}, H<:Hessian{T,RT}} = Hessian11a(h1,ref1)

struct Hessian22m{T,RT <: Ref{T},H1 <: Hessian{T,RT},H2 <: Hessian{T,RT},H12,H21} <: Hessian{T,RT}
    h1::H1
    h2::H2
    h12::H12
    h21::H21
    ref1::RT
    ref2::RT
end
struct Hessian11a{T,RT <: Ref{T}, H <: Hessian{T,RT}} <: Hessian{T,RT}
    h1::H
    ref::RT
end
Hessian11a(::HessianNull{T,RT},ref::RT) where {T,RT <: Ref{T}} = HessianNull{T,RT}()

struct HessianSum{T,RT,I,H <: Hessian{T,RT}} <: Hessian{T,RT}
    inner::I
    hs::Vector{H}
end
struct HessianIfElse{T, RT, H1 <: Hessian{T,RT},H2 <: Hessian{T,RT}} <: Hessian{T,RT}
    h1::H1
    h2::H2
    bref::RefValue{Bool}
end


Hessian(e::Real,d::GradientNull{T,RT},indexer = nothing) where {T, RT} = HessianNull{T,RT}()
for (T1,T2) in [(:(GradientNull{T,RT}),:(GradientNull{T,RT})), (:(GradientNull{T,RT}),:(Gradient{T,RT})), (:(Gradient{T,RT}),:(GradientNull{T,RT}))]
    @eval Hessian(d1::G1,d2::G2,indexer = nothing) where {T, RT, G1 <: $T1, G2 <: $T2} = HessianNull{T,RT}()
end
Hessian(e::V,::G,indexer = nothing)  where {T, RT,G <: Gradient{T,RT}, V <: Union{ExpressionNull, AbstractVariable,AbstractParameter}} = HessianNull{T,RT}()
Hessian(d1::G,d2::G,indexer = nothing) where {T, RT,G <: Gradient0{T,RT}} = HessianD00S{T,RT}(index(d1)>=index(d2) ? set_indexer!(indexer,index(d1),index(d2)) : 0,index(d1) >= index(d2))
Hessian(d1::G,d2::G,::Nothing) where {T, RT,G <: Gradient0{T,RT}} = HessianD00{T,RT}(index(d1),index(d2),index(d1) >= index(d2))
Hessian(d1::G1,d2::G2, indexer = nothing) where {T, RT,G1 <: Gradient0{T,RT}, G2 <: Union{Gradient1,Gradient2F1,Gradient2F2}} = HessianD10(Hessian(d1,d2.d1,indexer),ref(d2))
Hessian(d1::G1,d2::G2, indexer = nothing) where {T, RT,G1 <: Union{Gradient1,Gradient2F1,Gradient2F2}, G2 <: Gradient0{T,RT}} = HessianD10(Hessian(d1.d1,d2,indexer),ref(d1))
Hessian(d1::G1,d2::G2, indexer = nothing) where {G1 <: Union{Gradient1,Gradient2F1,Gradient2F2}, G2 <: Union{Gradient1,Gradient2F1,Gradient2F2}}= HessianD11(Hessian(d1.d1,d2.d1,indexer),ref(d1),ref(d2))
Hessian(d1::G1,d2::G2, indexer = nothing) where {G1 <: Union{Gradient1,Gradient2F1,Gradient2F2}, G2 <: Gradient2} = HessianD21(Hessian(d1.d1,d2.d1,indexer),Hessian(d1.d1,d2.d2,indexer),ref(d1),ref1(d2),ref2(d2))
Hessian(d1::G1,d2::G2, indexer = nothing) where {G1 <: Gradient2, G2 <: Union{Gradient1,Gradient2F1,Gradient2F2}} = HessianD21(Hessian(d1.d1,d2.d1,indexer),Hessian(d1.d2,d2.d1,indexer),ref(d2),ref1(d1),ref2(d1))
Hessian(d1::G1,d2::G2, indexer = nothing) where {T,RT,G1 <: Gradient0{T,RT}, G2 <: Gradient2{T,RT}} = HessianD20(Hessian(d1,d2.d1,indexer),Hessian(d1,d2.d2,indexer),ref1(d2),ref2(d2))
Hessian(d1::Gradient2{T,RT,F,F1,F2},d2::Gradient0, indexer = nothing) where {T,RT,F,F1,F2} = HessianD20(Hessian(d1.d1,d2,indexer),Hessian(d1.d2,d2,indexer),ref1(d1),ref2(d1))
Hessian(d1::Gradient2{T,RT,F1,F11,F12},d2::Gradient2{T,RT,F2,F21,F22}, indexer = nothing) where {T,RT,F1,F11,F12,F2,F21,F22} = Hessian02(Hessian(d1.d1,d2.d1,indexer),Hessian(d1.d1,d2.d2,indexer),Hessian(d1.d2,d2.d1,indexer),Hessian(d1.d2,d2.d2,indexer),ref1(d1),ref2(d1),ref1(d2),ref2(d2))
Hessian(e::E,d, indexer = nothing) where E <: Expression1 = Hessian11(e,d,indexer)
Hessian(e::Expression1{T,RT,F,E},d, indexer = nothing) where {T,RT,F<:Union{typeof(+),typeof(-)},E} = Hessian11a(Hessian(e.e1,d.d1,indexer),ref(d))
Hessian(e::Expression2{T,RT,F,E1,E2}, d, indexer = nothing) where {T,RT,F,E1,E2} = Hessian22(e,d,indexer)
Hessian(e::Expression2{T,RT,F,E1,E2}, d, indexer = nothing) where {T,RT,F,E1 <: Real,E2} = Hessian11F1(e,d,indexer)
Hessian(e::Expression2{T,RT,F,E1,E2}, d, indexer = nothing) where {T,RT,F,E1,E2 <: Real} = Hessian11F2(e,d,indexer)
Hessian(e::Expression2{T,RT,typeof(*),E1,E2},d,indexer = nothing) where {T,RT,E1,E2} = Hessian22m(Hessian(e.e1,d.d1,indexer),Hessian(e.e2,d.d2,indexer),Hessian(d.d1,d.d2,indexer),Hessian(d.d2,d.d1,indexer),ref1(d),ref2(d))
Hessian(e::Expression2{T,RT,F,E1,E2},d,indexer = nothing) where {T,RT,F<:Union{typeof(+),typeof(-)},E1,E2} = Hessian22a(Hessian(e.e1,d.d1,indexer),Hessian(e.e2,d.d2,indexer),ref1(d),ref2(d))
Hessian(e::Expression2{T,RT,F,E1,E2}, d,indexer = nothing) where {T,RT,F<:Union{typeof(+),typeof(-),typeof(*)},E1 <: Real,E2 <: Expression} = Hessian11a(Hessian(e.e2,d.d1,indexer),ref(d))
Hessian(e::Expression2{T,RT,F,E1,E2}, d,indexer = nothing) where {T,RT,F<:Union{typeof(+),typeof(-),typeof(*),typeof(/)},E1 <: Expression,E2 <: Real} = Hessian11a(Hessian(e.e1,d.d1,indexer),ref(d))
Hessian(e::ExpressionSum{T,RT,E,I1},d::GradientSum{T,RT,D,I2},indexer = nothing) where {T,RT,E,D,I1,I2} = HessianSum(Hessian(inner(e),inner(d),indexer),[Hessian(e,d,indexer) for (e,d) in zip(e.es,d.ds)])
Hessian(e::ExpressionSum{T,RT,E,Nothing},d::GradientSum{T,RT,D,Nothing},indexer = nothing) where {T,RT,E,D} = HessianSum(nothing,[Hessian(e,d,indexer) for (e,d) in zip(e.es,d.ds)])


function Hessian(d1::GradientSum{T,RT,D1,I1},d2::GradientSum{T,RT,D2,I2},indexer = nothing) where {T,RT,D1,D2,I1,I2}
    hinner = Hessian(inner(d1),d2,indexer)
    hs = [Hessian(d,d2,indexer) for d in d1.ds]

    return HessianSum(hinner,hs)
end
function Hessian(d1::GradientSum{T,RT,D1,I1},d2::GradientSum{T,RT,D2,Nothing},indexer = nothing) where {T,RT,D1,D2,I1}
    hinner = Hessian(inner(d1),d2,indexer)
    hs = [Hessian(d,d2,indexer) for d in d1.ds]
    
    return HessianSum(hinner,hs)
end
function Hessian(d1::GradientSum{T,RT,D1,I1},d2::G,indexer = nothing) where {T,RT,D1,D2,I1,I2,G <: Gradient}
    hinner = Hessian(inner(d1),d2,indexer)
    hs = [Hessian(d,d2,indexer) for d in d1.ds]
    
    return HessianSum(hinner,hs)
end
function Hessian(d1::G,d2::GradientSum{T,RT,D2,I2},indexer = nothing) where {T,RT,G <: Gradient,D2,I2}
    hinner = Hessian(d1,inner(d2),indexer)
    hs = [Hessian(d1,d,indexer) for d in d2.ds]
    
    return HessianSum(hinner,hs)
end

function Hessian(d1::GradientSum{T,RT,D1,Nothing},d2::GradientSum{T,RT,D2,I2},indexer = nothing) where {T,RT,D1,D2,I2}
    hs = [Hessian(d,d2,indexer) for d in d1.ds]
    
	  return HessianSum(nothing, hs)
end
function Hessian(d1::GradientSum{T,RT,D1,Nothing},d2::GradientSum{T,RT,D2,Nothing},indexer = nothing) where {T,RT,D1,D2}
    hs = [Hessian(d,d2,indexer) for d in d1.ds]
    
	  return HessianSum(nothing, hs)
end
function Hessian(d1::GradientSum{T,RT,D1,Nothing},d2::G,indexer = nothing) where {T,RT, D1,D2,I2,G <: Gradient}
    hs = [Hessian(d,d2,indexer) for d in d1.ds]
    
	  return HessianSum(nothing, hs)
end
function Hessian(d1::G,d2::GradientSum{T,RT,D2,Nothing},indexer = nothing) where {T, RT,G <: Gradient, D2}
    hs = [Hessian(d1,d,indexer) for d in d2.ds]
    
	  return HessianSum(nothing, hs)
end

Hessian(e::E,d,indexer = nothing) where E <: ExpressionIfElse = HessianIfElse(Hessian(e.e1,d.d1,indexer),Hessian(e.e2,d.d2,indexer),e.bref)
