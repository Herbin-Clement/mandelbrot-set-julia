@time using Images
# @time using VideoIO

function color(z::ComplexF64, c::ComplexF64, limit::Float64, depth::Int)::UInt8
    count = 0
    for _ in 1:depth
        z = z * z + c
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

function mandelbrot(c::ComplexF64, xmin::Float64, xmax::Float64, ymin::Float64, ymax::Float64, w::Int64, h::Int64, depth::Int64, limit::Float64)::Array{UInt8, 2}
    xshift = (xmax - xmin) / (w - 1)
    yshift = (ymax - ymin) / (h - 1)
    img = Array{UInt8,2}(undef, h, w)
    y = ymin
    for i in 1:h
        x = xmin
        for j in 1:w
            z = complex(x, y)
            img[j, i] = color(z, c, limit, depth)
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
    nb_img = 1
    xmin = -2.0
    xmax = 2.0
    ymin = -2.0
    ymax = 2.0
    w = 25000
    h = 25000
    depth = 100
    limit = 5000.0
    i = 0.75
    j = 0.25
    @time img = mandelbrot(complex(i, j), xmin, xmax, ymin, ymax, w, h, depth, limit)
    # imgs = Array{Array{UInt8, 2}, 1}(undef, nb_img)
    # for i in -1:0.25:1
    #     for j in -1:0.25:1
    #         if i != 0 && j != 0 
    #             @time img = mandelbrot(complex(i, j), xmin, xmax, ymin, ymax, w, h, depth, limit)
    #             save("img/c_$i-$j.png", img)
    #         end
    #     end
    # end
    save("img/c.png", img)
end

main()