$team_set = []
$pl_actor = nil
$sel_body = nil

begin
  Dir["*.log"].each{|i| File.delete((Dir.getwd + '/'+i))}
rescue
end