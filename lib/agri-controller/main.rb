#!ruby
#coding:utf-8
#require "load_scripts"
#include Loger
#include Time_module
#include WR1010
#require "error_caption"
#require "setting_io"
#include Setting_io
module AgriController
  module_function
  def main
    loop do
      error_caption("./cgi-bin/log/errors") do
        if RUBY_PLATFORM.include?("mswin")
          main_new
        else#linux
          main_linux
        end
      end
      Thread.list.each{|th| th.kill unless th==Thread.main}
      p "MAIN:  reload_loop"
      p Thread.list
      sleep 2
    end
  end
  alias kr_run main
end
=begin
##
=危機対策
*電気
  *停電
    *UPSをつける
    *UPSが作動したときのプログラム（未）
  *平常時のランプ(何かあったら消えることで通知)
  *完全アナログ的に人間が対応できるようにしておく。
    *手動ボタン、切替スイッチなど
*マシンPC
  *マザーボード、メモリ、HDの故障など
    *おそらく停止してしまう,又は意図しない動作
    *コピーマシン（予備機の準備）(未)
    *heart beatなどソフト的なクラスター化(大規模になってしまうが)
      *停電と同じ措置
      *手動入力、アナログ機器で対応
    *記録などで判断できるようにしておく
*入力
  *特に、温度データが来なくなったときの手順を組み込んでおく。
  *なんらかの確認手段、別途の監視手段など(未)
  *記帳などによる確認
  *定期的な手動点検、立会いチェックなど
  *プログラム的には予測可能な限りの対応をしておく
*出力
  *入力とほぼ同じ対策
  *リスク分散したもの
  
=end

#AgriController::run
