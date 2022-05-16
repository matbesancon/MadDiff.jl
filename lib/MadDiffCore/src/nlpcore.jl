# Jacobian
struct JacobianEntry{T,E <: Gradient{T}} <: Entry{T}
    index::Int
    e::E
end
# struct Jacobian{G <: Gradient, I}
#     inner::I
#     ds::Vector{Tuple{Int,G}}
# end
# @inline function (J::Jacobian{G,I})(y,x,p=nothing) where {G,I}
#     inner(J)(y,x)
#     @simd for i in eachindex(J.ds)
#         (j,d) = J.ds[i]
#         d((j,y),x,p)
#     end
# end
# @inline function (J::Jacobian{G,Nothing})(y,x,p=nothing) where G
#     @simd for i in eachindex(J.ds)
#         (j,d) = J.ds[i]
#         d((j,y),x,p)
#     end
# end
@inline (e::JacobianEntry{T,E})(y,x,p=nothing) where {T,E} = e.e((index(e),y),x,p)
# Jacobian(s::Sink{Field}) = Jacobian(inner(s))
Jacobian(f::Field1{G,I},indexer = nothing) where {G,I} = Field1(Jacobian(inner(f),indexer),[JacobianEntry(index(ie),Gradient(ie.e,(index(ie),indexer))) for ie in f.es])
Jacobian(f::Field1{G,Nothing},indexer = nothing) where G = Field1(nothing,[JacobianEntry(index(ie),Gradient(ie.e,(index(ie),indexer))) for ie in f.es])

# Lagrangian Hessian
struct LagrangianEntry{T,E <: Hessian{T}} <: Entry{T}
    index::Int
    e::E
end
struct LagrangianHessian{F}
    f::F
end
@inline (laghess::LagrangianHessian)(z,x,p,l,s) = _eval_laghess(laghess.f,z,x,p,l,s)
@inline function _eval_laghess(f::Field1{E,I},z,x,p,l,s) where {E,I}
    _eval_laghess(inner(f),z,x,p,l,s)
    @simd for i in eachindex(f.es)
        f.es[i](z,x,p,l)
    end
end
@inline _eval_laghess(h::H,z,x,p,l,s) where H <: Hessian = h(z,x,p,s)
@inline (lagentry::LagrangianEntry{E})(z,x,p,l) where E = lagentry.e(z,x,p,l[index(lagentry)])

LagrangianHessian(obj,grad,con,jac,indexer=nothing) = LagrangianHessian(_LagrangianHessian(obj,grad,con,jac,indexer))

function _LagrangianHessian(obj,grad,con::Field1{E1,I1},jac::Field1{E2,I2},indexer = nothing) where {E1,E2,I1,I2}
    Field1(_LagrangianHessian(obj,grad,inner(con),inner(jac),indexer),
           [LagrangianEntry(index(con.es[i]),Hessian(con.es[i].e,jac.es[i].e,indexer)) for i in eachindex(con.es)])
end

function _LagrangianHessian(obj,grad,con::Field1{E1,Nothing},jac::Field1{E2,Nothing},indexer = nothing) where {E1,E2}
    Field1(Hessian(obj,grad,indexer),[LagrangianEntry(index(con.es[i]),Hessian(con.es[i].e,jac.es[i].e,indexer)) for i in eachindex(con.es)])
end

function _LagrangianHessian(obj,grad,con::FieldNull,jac::FieldNull,indexer = nothing) where {E1,E2}
    Hessian(obj,grad,indexer)
end

Field1(inner,::Vector{LagrangianEntry{HessianNull{T}}}) where T = inner

# NLPCore
struct NLPCore
    obj::Expression
    con::Field
    grad::Gradient
    jac::Field
    hess::MadDiffCore.LagrangianHessian
    jac_sparsity::Vector{Tuple{Int,Int}}
    hess_sparsity::Vector{Tuple{Int,Int}}
end

NLPCore(obj::Expression,con::Sink{Field}) = NLPCore(obj,con.inner)
function NLPCore(obj::Expression,con::Field)
    grad = Gradient(obj)
    jac,jac_sparsity = SparseJacobian(con)
    hess,hess_sparsity = SparseLagrangianHessian(obj,grad,con,jac)
    return NLPCore(obj,con,grad,jac,hess,jac_sparsity,hess_sparsity)
end

@inline function obj(nlpcore::NLPCore,x,p)
    non_caching_eval(nlpcore.obj,x,p)
end
@inline function cons!(nlpcore::NLPCore,x,y,p)
    non_caching_eval(nlpcore.con,y,x,p)
end
@inline function grad!(nlpcore::NLPCore,x,y,p)
    y .= 0
    nlpcore.obj(x,p)
    non_caching_eval(nlpcore.grad,y,x,p)
end
@inline function jac_coord!(nlpcore::NLPCore,x,J,p)
    J .= 0
    nlpcore.con(DUMMY,x,p)
    non_caching_eval(nlpcore.jac,J,x,p)
end
@inline function hess_coord!(nlpcore::NLPCore,x,lag,z,p; obj_weight = 1.0)
    z .= 0
    nlpcore.obj(x,p)
    nlpcore.con(DUMMY,x,p)
    nlpcore.grad(DUMMY,x,p)
    nlpcore.jac(DUMMY,x,p)
    nlpcore.hess(z,x,p,lag, obj_weight) ###
end


