using Comonicon, Base.Iterators, CSV, TerminalLoggers 
using Logging: global_logger
global_logger(TerminalLogger())
using ProgressLogging

@progress for i = 1:100
    if i == 50
        @info "Middle of computation" i
    elseif i == 70
        println("Normal output does not interfere with progress bars")
    end
    sleep(0.01)
end
@info "Done"