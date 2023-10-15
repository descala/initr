class Initr::PublicKey


  def self.to_hash(pubkey)
    if pubkey =~ / / and pubkey.split.size >= 3
      pubkey = pubkey.split.reverse
      return {"type" => pubkey.pop, "key" => pubkey.pop, "comment" => pubkey.reverse.join(" ")}
    elsif pubkey =~ / / and pubkey.split.size < 3
      return nil
    else
      return {"type" => "", "key" => pubkey, "comment" => ""}
    end
  end

end

