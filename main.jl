using Images

function color(c::ComplexF64, limit::Float64, depth::Int)::UInt8
    count = 0
    z_n = Array{ComplexF64,1}()
    z = 0 + 0im
    push!(z_n, z)
    for _ in 1:depth
        z = z * z + c
        push!(z_n, z)
        if norm(z) > limit
            break
        end
        count += 1
    end
    return trunc(UInt8, 255 * count / depth)
end

function norm(c::ComplexF64)::Float64
    return sqrt(real(c) * real(c) + imag(c) * imag(c))
end

function mandelbrot(xmin::Float64, xmax::Float64, ymin::Float64, ymax::Float64, w::Int64, h::Int64)::Array{UInt8, 2}
    xshift = (xmax - xmin) / (w - 1)
    yshift = (ymax - ymin) / (h - 1)
    img = Array{UInt8,2}(undef, h, w)
    y = ymin
    for i in 1:h
        x = xmin
        for j in 1:w
            c = complex(x, y)
            img[j, i] = color(c, 5.0, 100)
            x += xshift
        end
        y += yshift
    end
    return img
end

function printComplexArray(z_n::Array{ComplexF64})
    for z in z_n
        println(z)
    end
end

function main()
    img = mandelbrot(-2.0, 2.0, -2.0, 2.0, 8000, 8000)
    save("Test.png", img)
end

main()