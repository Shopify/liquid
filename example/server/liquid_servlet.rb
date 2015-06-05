class LiquidServlet < WEBrick::HTTPServlet::AbstractServlet
  def do_GET(req, res)
    handle(:get, req, res)
  end

  def do_POST(req, res)
    handle(:post, req, res)
  end

  private

  def handle(type, req, res)
    @request = req
    @response = res

    @request.path_info =~ /(\w+)\z/
    @action = $1 || 'index'
    @assigns = send(@action) if respond_to?(@action)

    @response['Content-Type'] = "text/html"
    @response.status = 200
    @response.body = Liquid::Template.parse(read_template).render(@assigns, filters: [ProductsFilter])
  end

  def read_template(filename = @action)
    File.read("#{__dir__}/templates/#{filename}.liquid")
  end
end
