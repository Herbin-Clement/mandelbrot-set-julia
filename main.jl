@time using Images
# @time using VideoIO

function color(c::ComplexF64, limit::Float64, depth::Int)::UInt8
    count = 0
    z = complex(0., 0.)
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

function mandelbrot(xmin::Float64, xmax::Float64, ymin::Float64, ymax::Float64, w::Int64, h::Int64, depth::Int64, limit::Float64)::Array{UInt8, 2}
    xshift = (xmax - xmin) / (w - 1)
    yshift = (ymax - ymin) / (h - 1)
    img = Array{UInt8,2}(undef, h, w)
    ylength = ymax - ymin
    Threads.@threads for i in 1:h
        y = ymin + i * yshift
        x = xmin
        for j in 1:w
            c = complex(x, y)
            img[i, j] = color(c, limit, depth)
            x += xshift
        end
    end
    return img
end

function printComplexArray(z_n::Array{ComplexF64})
    for z in z_n
        println(z)
    end
end

function main()
    println("Number of thread: $(Threads.nthreads())")
    nb_img = 1
    xmin = -2.0
    xmax = 2.0
    ymin = -2.0
    ymax = 2.0
    w = 8000
    h = 8000
    depth = 100
    limit = 5.0
    @time img = mandelbrot(xmin, xmax, ymin, ymax, w, h, depth, limit)
    save("c.png", img)
    # imgs = Array{Array{UInt8, 2}, 1}(undef, nb_img)
    # for i in -1:0.25:1
    #     for j in -1:0.25:1
    #         if i != 0 && j != 0 
    #             @time img = mandelbrot(complex(i, j), xmin, xmax, ymin, ymax, w, h, depth, limit)
    #             save("img/c_$i-$j.png", img)
    #         end
    #     end
    # end
    # save("rgb.png", colorview(RGB, rand(3,256,256)))
    # println(typeof(rand(3, 256, 256)))
    # println(typeof(img))
end

main()