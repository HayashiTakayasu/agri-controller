#!ruby
#coding:utf-8
module AgriController
  module Web
  module_function
    def html_head(title="kansi_htm",tuika='')
    head=<<EOS
    <html>
      <head>
        <meta http-equiv="Content-Language" content="ja" />
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8" />
        #{tuika}
          <link rel="stylesheet" type="text/css" href="../css/str.css" title="str"/>
        <title>#{title}</title>
      </head>
      <body>
EOS
    end

    def html_end
    _end='
      </body>
    </html>'
    return _end
    end
    
    def html_head_refresh(title,time)
      #time:should be able to convert Integer
      str= <<eos
  <META HTTP-EQUIV="Refresh" CONTENT="#{time.to_s};URL=./main.cgi">
eos
      html_head(title,str)
    end
  end
end

if $0==__FILE__
print Web::html_end
end
