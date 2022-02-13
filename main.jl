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

function processImage(dir::String, w::Int, h::Int, zlimit::Float64, x_center::Float64, y_center::Float64, limit::Float64, scale::Float64, space::Float64)
    num_img = 1
    nb_img = getNumberOfImage(space, scale, limit)
    imgs = Array{Array{UInt8, 2}, 1}(undef, nb_img)
    while space > limit
        space = scale * space
        xmin = - space + x_center
        xmax = space + x_center
        ymin = - space + y_center
        ymax = space + y_center
        xlims = xmax - xmin
        depth = trunc(Int, 50 + log10(((4 / abs(xlims)))) ^ 5)
        print("iter: $depth ")
        @time imgs[num_img] = mandelbrot(xmin, xmax, ymin, ymax, w, h, depth, zlimit)
        save("$dir/$num_img.png", imgs[num_img])
        num_img += 1
    end
end

function main()
    println("Number of thread: $(Threads.nthreads())")
    dir = "img2"
    if Base.Filesystem.ispath("img2")
        Base.Filesystem.rm("img2", recursive=true)
    end
    w = 800
    h = 800
    zlimit = 5.0
    x_center = - 0.75
    y_center = 0.1
    space = 2.0
    limit = 0.0001
    scale = 0.95
    processImage(dir, w, h, zlimit, x_center, y_center, limit, scale, space)
    # processVideo(string(pwd(), "/", dir))
end

main()