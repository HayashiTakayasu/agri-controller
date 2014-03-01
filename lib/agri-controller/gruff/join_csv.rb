require "csv"
require "time"

module AgriController

def delete_comment(ary,comment_count)
  comment_count.times{ary.shift}
  
  ary
end

def to_h(ary,time_line=0)
  hash={}
  ary.each do |list|
    t=list.delete_at(time_line=0)
    t=Time.parse(t)
    hash[t]=list
  end
  hash
end

module_function
def join_csv(f1,f2,comment_f1=0,comment_f2=0)
  a=CSV.read(f1)
  a=delete_comment(a,comment_f1)
  size=a[0].size
  hash1=to_h(a,0)
  #hash1
  
  b=CSV.read(f2)
  b=delete_comment(b,comment_f1)
  hash2=to_h(b,0)

  new_hash={}
  hash2.each do |i,j|
    if hash1.has_key?(i)
    else
      hash1[i]=Array.new(size-1){"false"}
    end
    new_hash[i]=hash1[i].concat(j)
  end
  ary=new_hash.sort_by{|i,j| i}
  ary.map{|i| i.flatten}
end

end
if $0==__FILE__
  f1=ARGV[0] || "../mch383/thermo_data.csv"
  f2=ARGV[1] || "../mch383_2/thermo_data.csv"
  to_file=ARGV[2]
  comment_f1=1
  comment_f2=1
  list=join_csv(f1,f2,comment_f1,comment_f2)
  if to_file
    CSV.open(to_file,"w") do |csv|    
      list.each do |i|
       i[0]=i[0].strftime("%Y/%m/%d %H:%M:%S")
        csv << i
    end
    end
  end
end
