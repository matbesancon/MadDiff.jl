# We only do a rough test of printing

@test begin
    println("Test printing")
    xx= Variable()
    pp= Parameter()
    m = SimpleNL.Model(Ipopt.Optimizer)
    u = [variable(m) for i=1:10]
    v = [parameter(m) for i=1:10]
    c = constraint(m,u[1]+u[2]==0)
    
    show(stdout, MIME"text/plain"(),xx)
    show(stdout, MIME"text/plain"(),pp)
    show(stdout, MIME"text/plain"(),xx[1])
    show(stdout, MIME"text/plain"(),pp[1])
    # show(stdout, MIME"text/plain"(),c)
    # show(stdout, MIME"text/plain"(),u[2])
    # show(stdout, MIME"text/plain"(),v[3])
    # show(stdout, MIME"text/plain"(),m)
    
    for (x,p) in [(xx,pp), (u,v), ([Variable(i) for i=1:10],[Parameter(i) for i=1:10])]
        show(stdout, MIME"text/plain"(),2 + 7*sum(1 +beta(sin(x[1]^x[2]+erf(p[2])/p[1])^2,cos(p[1]*x[4])/x[5]^2-x[3])+sin(x[i]) + beta(p[2]*x[1],3) for i=1:7))
        show(stdout, MIME"text/plain"(),1 - (1/p[1])^2 - sum(-sin(sin(sin(cos(beta(1,x[i]/x[i+1])+p[2])-1.)+4)^9)/abs2(x[3]) for i=1:7))
    end
    
    true
end
