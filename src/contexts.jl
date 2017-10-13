#######
# Tag #
#######

struct Tag{T} end

@generated function Tag(::T) where {T}
    return quote
        $(Expr(:meta, :inline))
        Tag{$(object_id(T))}()
    end
end

###########
# Context #
###########

abstract type Context{S,T} end

Base.show(io::IO, ::Context{S,T}) where {S,T} = print(io, "$S{$T}()")

###############################################
# method stubs for macros (see src/macros.jl) #
###############################################

function _hook end

@inline hook(::Val{world}, ctx::Context, meta, f, args...) where {world} = _hook(ctx, meta, f, args...)

function _execution end

@inline execution(::Val{world}, ctx::Context, meta, f, args...) where {world} = _execution(ctx, meta, f, args...)

@inline _isprimitive(args...) = Val(false)

# passing world age here forces recompilation
@generated function isprimitive(::Val{world}, ctx::Context, meta, f::F, args...) where {world,F}
    if F <: Core.Builtin
        body = :(Val(true))
    else
        body = :($Cassette._isprimitive(ctx, meta, f, args...))
    end
    return quote
        $(Expr(:meta, :inline))
        $(body)
    end
end