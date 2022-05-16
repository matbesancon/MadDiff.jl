struct HessianNull{T} <: Hessian{T} end
struct HessianD21{T,H1,H2} <: Hessian{T}
    h1::H1
    h2::H2
    ref::MyRef{T}
    ref1::MyRef{T}
    ref2::MyRef{T}
end
struct Hessian11{T,F,H1,H11} <: Hessian{T}
    h1::H1
    h11::H11
    fref::MyRef{T}
    ref::MyRef{T}

    function Hessian11(e::Expression1{T,F,E},d, indexer = nothing) where {T,F,E}
        h1 = Hessian(e.e1,d.d1,indexer)
        h11= Hessian(d.d1,d.d1,indexer)
        return new{T,F,typeof(h1),typeof(h11)}(h1,h11,ref(e.e1),ref(d))
    end
end
struct Hessian11F1{T,F,H1,H11,R} <: Hessian{T}
    a::R
    h1::H1
    h11::H11
    fref::MyRef{T}
    ref::MyRef{T}
    function Hessian11F1(e::Expression2{T,F,E1,E2}, d,indexer = nothing) where {T,F,E1 <: Real,E2} 
        h1 = Hessian(e.e2,d.d1,indexer)
        h11= Hessian(d.d1,d.d1,indexer)
        return new{T,F,typeof(h1),typeof(h11),typeof(e.e1)}(e.e1,h1,h11,ref(e.e2),ref(d))
    end
 end
struct Hessian11F2{T,F,H1,H11,R} <: Hessian{T}
    a::R
    h1::H1
    h11::H11
    fref::MyRef{T}
    ref::MyRef{T}
    function Hessian11F2(e::Expression2{T,F,E1,E2}, d,indexer = nothing) where {T,F,E1,E2 <: Real}
        h1 = Hessian(e.e1,d.d1,indexer)
        h11= Hessian(d.d1,d.d1,indexer)
        return new{T,F,typeof(h1),typeof(h11),typeof(e.e2)}(e.e2,h1,h11,ref(e.e1),ref(d))
    end
end
struct Hessian02{T,H11,H12,H21,H22} <: Hessian{T}
    h11::H11
    h12::H12
    h21::H21
    h22::H22
    ref11::MyRef{T}
    ref12::MyRef{T}
    ref21::MyRef{T}
    ref22::MyRef{T}
end
struct Hessian22{T,F,H1,H2,H11,H12,H21,H22} <: Hessian{T}
    h1::H1
    h2::H2
    h11::H11
    h12::H12
    h21::H21
    h22::H22
    fref1::MyRef{T}
    fref2::MyRef{T}
    ref1::MyRef{T}
    ref2::MyRef{T}

    function Hessian22(e::Expression2{T,F,E1,E2},d,indexer = nothing) where {T,F,E1,E2}
        h1 = Hessian(e.e1,d.d1,indexer)
        h2 = Hessian(e.e2,d.d2,indexer)
        h11= Hessian(d.d1,d.d1,indexer)
        h12= Hessian(d.d1,d.d2,indexer)
        h21= Hessian(d.d2,d.d1,indexer)
        h22= Hessian(d.d2,d.d2,indexer)
        new{T,F,typeof(h1),typeof(h2),typeof(h11),typeof(h12),typeof(h21),typeof(h22)}(h1,h2,h11,h12,h21,h22,ref(e.e1),ref(e.e2),ref1(d),ref2(d))
    end
end
struct HessianD00{T} <: Hessian{T}
    index1::Int
    index2::Int
    islower::Bool
end
struct HessianD00S{T} <: Hessian{T}
    index::Int
    islower::Bool
end
struct HessianD20{T,H1 <: Hessian{T},H2 <: Hessian{T}} <: Hessian{T}
    h1::H1
    h2::H2
    ref1::MyRef{T}
    ref2::MyRef{T}
end
struct HessianD10{T,H <: Hessian{T}} <: Hessian{T}
    h::H
    ref::MyRef{T}
end
struct HessianD11{T,H <: Hessian{T}} <: Hessian{T}
    h::H
    ref1::MyRef{T}
    ref2::MyRef{T}
end
struct Hessian22a{T,H1 <: Hessian{T},H2 <: Hessian{T}} <: Hessian{T}
    h1::H1
    h2::H2
    ref1::MyRef{T}
    ref2::MyRef{T}
end
struct Hessian22m{T,H1 <: Hessian{T},H2 <: Hessian{T},H12,H21} <: Hessian{T}
    h1::H1
    h2::H2
    h12::H12
    h21::H21
    ref1::MyRef{T}
    ref2::MyRef{T}
end
struct Hessian11a{T,H <: Hessian{T}} <: Hessian{T}
    h1::H
    ref::MyRef{T}
end
struct HessianSum{T,I,H <: Hessian{T}} <: Hessian{T}
    inner::I
    hs::Vector{H}
end

@inline function (h::HessianSum{T,I,H})(z,x,p=nothing,h0=1) where {T,I,H} 
    inner(h)(z,x,p,h0)
    @simd for i in eachindex(h.hs)
        @inbounds h.hs[i](z,x,p,h0)
    end
end
@inline function (h::HessianSum{T,Nothing,H})(z,x,p=nothing,h0=1) where {T,H}
    @simd for i in eachindex(h.hs)
        @inbounds h.hs[i](z,x,p,h0)
    end
end

@inline (::HessianNull{T})(z,x,p=nothing,h0=1) where T = nothing
@inline function (h::HessianD00{T})(z,x,p=nothing,h0 = 1) where T
    islower(h) && @inbounds z[index1(h)::Int,index2(h)::Int] += h0
    return 
end
@inline function (h::HessianD00S{T})(z,x,p=nothing,h0 = 1) where T
    islower(h) && @inbounds z[index(h)::Int] += h0
    return 
end
@inline function (h::HessianD10{T,H})(z,x,p=nothing,h0 = 1) where {T,H}
    h.h(z,x,p,h0*refval(h))
    return
end
@inline function (h::HessianD11{T,H})(z,x,p=nothing,h0 = 1) where {T,H}
    h.h(z,x,p,h0*refval1(h)*refval2(h))
    return
end
@inline function (h::HessianD21{T,H1,H2})(z,x,p=nothing,h0=1) where {T,H1,H2}
    h.h1(z,x,p,h0*refval(h)*refval1(h))
    h.h2(z,x,p,h0*refval(h)*refval2(h))
    return
end
@inline function (h::HessianD20{T,H1,H2})(z,x,p=nothing,h0=1) where {T,H1,H2}
    h.h1(z,x,p,h0*refval1(h))
    h.h2(z,x,p,h0*refval2(h))
end
@inline function (h::Hessian02{T,H11,H12,H21,H22})(z,x,p=nothing,h0=1) where {T,H11,H12,H21,H22}
    h.h11(z,x,p,h0*refval11(h)*refval21(h))
    h.h12(z,x,p,h0*refval11(h)*refval22(h)) 
    h.h21(z,x,p,h0*refval12(h)*refval21(h)) 
    h.h22(z,x,p,h0*refval12(h)*refval22(h))
    return
end
@inline function (h::Hessian11a{T,H})(z,x,p=nothing,h0=1) where {T,H}
    h.h1(z,x,p,h0*refval(h))
    return
end
@inline function (h::Hessian22a{T,H1,H2})(z,x,p=nothing,h0=1) where {T,H1,H2}
    h.h1(z,x,p,h0*refval1(h))
    h.h2(z,x,p,h0*refval2(h))
    return
end
@inline function (h::Hessian22m{T,H1,H2,H12})(z,x,p=nothing,h0=1) where {T,H1,H2,H12}
    h.h1(z,x,p,h0*refval1(h))
    h.h2(z,x,p,h0*refval2(h))
    h.h12(z,x,p,h0)
    h.h21(z,x,p,h0)
    return
end

Hessian(e::ExpressionSum{T,E,I1},d::GradientSum{T,D,I2},indexer = nothing) where {T,E,D,I1,I2} = HessianSum(Hessian(inner(e),inner(d),indexer),[Hessian(e,d,indexer) for (e,d) in zip(e.es,d.ds)])
Hessian(e::ExpressionSum{T,E,Nothing},d::GradientSum{T,D,Nothing},indexer = nothing) where {T,E,D} = HessianSum(nothing,[Hessian(e,d,indexer) for (e,d) in zip(e.es,d.ds)])
Hessian(e::Variable{T},::G,indexer)  where {T <: AbstractFloat, G <: Gradient} = HessianNull{T}()
Hessian(e::Parameter{T},::G,indexer) where {T <: AbstractFloat, G <: Gradient} = HessianNull{T}()
Hessian(e::Constant{T},::G,indexer) where {T <: AbstractFloat, G <: Gradient} = HessianNull{T}()
Hessian(d1::G,d2::GradientNull{T},indexer) where {T,G <: Gradient} = HessianNull{T}()
Hessian(d1::GradientNull{T},d2::G,indexer) where {T,G <: Gradient} = HessianNull{T}()
Hessian(d1::GradientNull{T},d2::GradientNull{T},indexer) where T = HessianNull{T}()
Hessian(d1::Gradient0{T},d2::Gradient0{T},indexer) where T = HessianD00S{T}(index(d1)>=index(d2) ? set_indexer!(indexer,index(d1),index(d2)) : 0,index(d1) >= index(d2))
Hessian(d1::Gradient0{T},d2::Gradient0{T},::Nothing) where T = HessianD00{T}(index(d1),index(d2),index(d1) >= index(d2))
Hessian(d1::Gradient0{T},d2::G1, indexer = nothing) where {T, G1 <: Union{Gradient1,Gradient2F1,Gradient2F2}} = HessianD10(Hessian(d1,d2.d1,indexer),ref(d2))
Hessian(d1::G1,d2::Gradient0{T}, indexer = nothing) where {T, G1 <: Union{Gradient1,Gradient2F1,Gradient2F2}} = HessianD10(Hessian(d1.d1,d2,indexer),ref(d1))
Hessian(d1::G1,d2::G2, indexer = nothing) where {G1 <: Union{Gradient1,Gradient2F1,Gradient2F2}, G2 <: Union{Gradient1,Gradient2F1,Gradient2F2}}= HessianD11(Hessian(d1.d1,d2.d1,indexer),ref(d1),ref(d2))
Hessian(d1::G1,d2::G2, indexer = nothing) where {G1 <: Union{Gradient1,Gradient2F1,Gradient2F2}, G2 <: Gradient2} = HessianD21(Hessian(d1.d1,d2.d1,indexer),Hessian(d1.d1,d2.d2,indexer),ref(d1),ref1(d2),ref2(d2))
Hessian(d1::G1,d2::G2, indexer = nothing) where {G1 <: Gradient2, G2 <: Union{Gradient1,Gradient2F1,Gradient2F2}} = HessianD21(Hessian(d1.d1,d2.d1,indexer),Hessian(d1.d2,d2.d1,indexer),ref(d2),ref1(d1),ref2(d1))
Hessian(d1::Gradient0{T},d2::Gradient2{T,F,F1,F2}, indexer = nothing) where {T,F,F1,F2} = HessianD20(Hessian(d1,d2.d1,indexer),Hessian(d1,d2.d2,indexer),ref1(d2),ref2(d2))
Hessian(d1::Gradient2{T,F,F1,F2},d2::Gradient0, indexer = nothing) where {T,F,F1,F2} = HessianD20(Hessian(d1.d1,d2,indexer),Hessian(d1.d2,d2,indexer),ref1(d1),ref2(d1))
Hessian(d1::Gradient2{T,F1,F11,F12},d2::Gradient2{T,F2,F21,F22}, indexer = nothing) where {T,F1,F11,F12,F2,F21,F22} = Hessian02(Hessian(d1.d1,d2.d1,indexer),Hessian(d1.d1,d2.d2,indexer),Hessian(d1.d2,d2.d1,indexer),Hessian(d1.d2,d2.d2,indexer),ref1(d1),ref2(d1),ref1(d2),ref2(d2))
Hessian(e::Expression1{T,F,E},d, indexer = nothing) where {T,F,E} = Hessian11(e,d,indexer)
Hessian(e::Expression2{T,F,E1,E2},d,indexer = nothing) where {T,F,E1,E2} = Hessian22(e,d,indexer)
Hessian(e::Expression2{T,F,E1,E2}, d,indexer = nothing) where {T,F,E1 <: Real,E2} = Hessian11F1(e,d,indexer)
Hessian(e::Expression2{T,F,E1,E2}, d,indexer = nothing) where {T,F,E1,E2 <: Real} = Hessian11F2(e,d,indexer)
Hessian(e::Expression2{T,typeof(*),E1,E2},d,indexer = nothing) where {T,E1,E2} = Hessian22m(Hessian(e.e1,d.d1,indexer),Hessian(e.e2,d.d2,indexer),Hessian(d.d1,d.d2,indexer),Hessian(d.d2,d.d1,indexer),ref1(d),ref2(d))
Hessian(e::Expression2{T,F,E1,E2},d,indexer = nothing) where {T,F<:Union{typeof(+),typeof(-)},E1,E2} = Hessian22a(Hessian(e.e1,d.d1,indexer),Hessian(e.e2,d.d2,indexer),ref1(d),ref2(d))
Hessian(e::Expression2{T,F,E1,E2}, d,indexer = nothing) where {T,F<:Union{typeof(+),typeof(-),typeof(*)},E1 <: Real,E2 <: Expression} = Hessian11a(Hessian(e.e2,d.d1,indexer),ref(d))
Hessian(e::Expression2{T,F,E1,E2}, d,indexer = nothing) where {T,F<:Union{typeof(+),typeof(-),typeof(*),typeof(/)},E1 <: Expression,E2 <: Real} = Hessian11a(Hessian(e.e1,d.d1,indexer),ref(d))
Hessian11a(::HessianNull{T},::MyRef{T}) where T = HessianNull{T}()
Hessian22a(::HessianNull{T},::HessianNull{T},::MyRef{T},::MyRef{T}) where T = HessianNull{T}()
Hessian22a(::HessianNull{T},h2::H,::MyRef{T},ref2::MyRef{T}) where {T,H<:Hessian} = Hessian11a(h2,ref2)
Hessian22a(h1::H,::HessianNull{T},ref1::MyRef{T},::MyRef{T}) where {T,H<:Hessian} = Hessian11a(h1,ref1)

# performance killer ---------------
function Hessian(d1::GradientSum{T,D1,I1},d2::GradientSum{T,D2,I2},indexer = nothing) where {T,D1,D2,I1,I2}
    @warn "This operation is expensive"
    hinner = Hessian(inner(d1),d2,indexer)
    hs = [Hessian(d,d2,indexer) for d in d1.ds]
    @inline function (z,x,p=nothing,h0=1)
        hinner(z,x,p,h0)
        @simd for i in eachindex(hs)
            @inbounds hs[i](z,x,p,h0)
        end
    end
end
function Hessian(d1::GradientSum{T,D1,Nothing},d2::GradientSum{T,D2,I2},indexer = nothing) where {T,D1,D2,I2}
    @warn "This operation is expensive"
    hs = [Hessian(d,d2,indexer) for d in d1.ds]
    @inline function (z,x,p=nothing,h0=1)
        @simd for i in eachindex(hs)
            @inbounds hs[i](z,x,p,h0)
        end
    end
end
function Hessian(d1::GradientSum{T,D1,I1},d2::GradientSum{T,D2,Nothing},indexer = nothing) where {T,D1,D2,I1}
    @warn "This operation is expensive"
    hinner = Hessian(inner(d1),d2,indexer)
    hs = [Hessian(d,d2,indexer) for d in d1.ds]
    @inline function (z,x,p=nothing,h0=1)
        hinner(z,x,p,h0)
        @simd for i in eachindex(hs)
            @inbounds hs[i](z,x,p,h0)
        end
    end
end
function Hessian(d1::GradientSum{T,D1,Nothing},d2::GradientSum{T,D2,Nothing},indexer = nothing) where {T,D1,D2}
    @warn "This operation is expensive"
    hs = [Hessian(d,d2,indexer) for d in d1.ds]
    @inline function (z,x,p=nothing,h0=1)
        @simd for i in eachindex(hs)
            @inbounds hs[i](z,x,p,h0)
        end
    end
end
function Hessian(d1::GradientSum{T,D1,I1},d2::G,indexer = nothing) where {T,D1,D2,I1,I2,G <: Gradient}
    @warn "This operation is expensive"
    hinner = Hessian(inner(d1),d2,indexer)
    hs = [Hessian(d,d2,indexer) for d in d1.ds]
    @inline function (z,x,p=nothing,h0=1)
        hinner(z,x,p,h0)
        @simd for i in eachindex(hs)
            @inbounds hs[i](z,x,p,h0)
        end
    end
end
function Hessian(d1::GradientSum{T,D1,Nothing},d2::G,indexer = nothing) where {T,D1,D2,I2,G <: Gradient}
    @warn "This operation is expensive"
    hs = [Hessian(d,d2,indexer) for d in d1.ds]
    @inline function (z,x,p=nothing,h0=1)
        @simd for i in eachindex(hs)
            @inbounds hs[i](z,x,p,h0)
        end
    end
end
function Hessian(d1::G,d2::GradientSum{T,D2,I2},indexer = nothing) where {T,G <: Gradient,D2,I2}
    @warn "This operation is expensive"
    hinner = Hessian(d1,inner(d2),indexer)
    hs = [Hessian(d1,d,indexer) for d in d2.ds]
    @inline function (z,x,p=nothing,h0=1)
        hinner(z,x,p,h0)
        @simd for i in eachindex(hs)
            @inbounds hs[i](z,x,p,h0)
        end
    end
end
function Hessian(d1::G,d2::GradientSum{T,D2,Nothing},indexer = nothing) where {T, G <: Gradient, D2}
    @warn "This operation is expensive"
    hs = [Hessian(d1,d,indexer) for d in d2.ds]
    @inline function (z,x,p=nothing,h0=1)
        @simd for i in eachindex(hs)
            @inbounds hs[i](z,x,p,h0)
        end
    end
end

islower(h) = h.islower
