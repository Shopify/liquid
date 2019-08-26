# frozen_string_literal: true

class LiquidServlet < WEBrick::HTTPServlet::AbstractServlet
  def get(req, res)
    handle(:get, req, res)
  end

  def post(req, res)
    handle(:post, req, res)
  end

  alias_method :do_GET, :get
  alias_method :do_POST, :post

  private

  def handle(_type, req, res)
    @request = req
    @response = res

    @request.path_info =~ /(\w+)\z/
    @action = Regexp.last_match(1) || 'index'
    @assigns = send(@action) if respond_to?(@action)

    @response['Content-Type'] = 'text/html'
    @response.status = 200
    @response.body = Liquid::Template.parse(read_template).render(@assigns, filters: [ProductsFilter])
  end

  def read_template(filename = @action)
    File.read("#{__dir__}/templates/#{filename}.liquid")
  end
end
