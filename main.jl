@time using Images
@time using VideoIO
@time using ProgressMeter
@time using FileIO

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

function getNumberOfImage(space::Float64, scale::Float64, limit::Float64)::Int
    count = 0
    while space > limit
        space = scale * space
        count += 1
    end
    return count
end

function main()
    println("Number of thread: $(Threads.nthreads())")
    dir = "/img"
    # if Base.Filesystem.ispath("img")
    #     Base.Filesystem.rm("img", recursive=true)
    # end
    # w = 2500
    # h = 2500
    # depth = 1000
    # limit = 5.0
    # num_img = 1
    # x_center = - 0.75
    # y_center = 0.1
    # space = 2.0
    # lims = 0.0001
    # scale = 0.95
    # nb_img = getNumberOfImage(space, scale, lims)
    # imgs = Array{Array{UInt8, 2}, 1}(undef, nb_img)
    # while space > lims
    #     space = scale * space
    #     xmin = - space + x_center
    #     xmax = space + x_center
    #     ymin = - space + y_center
    #     ymax = space + y_center
    #     xlims = xmax - xmin
    #     depth = trunc(Int, 50 + log10(((4 / abs(xlims)))) ^ 5)
    #     print("iter: $depth ")
    #     @time imgs[num_img] = mandelbrot(xmin, xmax, ymin, ymax, w, h, depth, limit)
    #     save("img/$num_img.png", imgs[num_img])
    #     num_img += 1
    # end
    processVideo(string(pwd(), dir))
end

function processVideo(dir::String)
    # imgnames = filter(x->occursin(".png",x), readdir(dir)) # Populate list of all .pngs
    # intstrings =  map(x->split(x,".")[1],imgnames) # Extract index from filenames
    # p = sortperm(parse.(Int,intstrings)) #sort files numerically
    # imgstack = []
    # for imgname in imgnames[p]
    #     push!(imgstack, load(string(pwd(), "/img/", imgname)))
    # end
    # encoder_options = (crf=23, preset="medium")
    # props = [:priv_data => ("crf"=>"22","preset"=>"medium")]
    # save("video.mp4", imgstack, framerate=30, encoder_options=encoder_options)

    imgnames = filter(x->occursin(".png",x), readdir(dir)) # Populate list of all .pngs
    intstrings =  map(x->split(x,".")[1], imgnames) # Extract index from filenames
    p = sortperm(parse.(Int, intstrings)) #sort files numerically
    imgnames = imgnames[p]

    encoder_options = (crf=23, preset="medium")

    firstimg = load(joinpath(dir, imgnames[1]))
    open_video_out("video.mp4", firstimg, framerate=24, encoder_options=encoder_options) do writer
        @showprogress "Encoding video frames.." for i in eachindex(imgnames)
            img = load(joinpath(dir, imgnames[i]))
            write(writer, img)
        end
    end
end

main()