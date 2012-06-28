def Object.wrt_binding(*words)
  return if words.size < 1
  buff = ""
  for i in 1...words.size
    buff += "@#{words[i]}=val;"
  end
  class_eval %{
    def #{words[0]}=(val);#{buff};end
  }
end
$alias_acount = 0
def Object.amend(method_name, &amendment)
  $alias_acount += 1
  class_eval %{
    @@proc#{$alias_acount} = amendment
    alias method#{$alias_acount} #{method_name}
    def #{method_name}(*args)
      method#{$alias_acount}(*args)
      @@proc#{$alias_acount}.call(*args)
    end
  }
end