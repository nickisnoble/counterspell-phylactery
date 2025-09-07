class Rack::Attack
  Rack::Attack.cache.store = Rails.cache

  track_time = 15.minutes
  max_suspicious_requests = 2

  WP_PATHS = %r{^\/(wp-admin|wp-login\.php|xmlrpc\.php|wp-content|wp-includes|wp-json|wp-cron\.php)}

  # Block requests that are either in the permanent blacklist OR are WordPress scans
  blocklist("block wordpress scanners") do |req|
    Rails.cache.read("rack_attack:block_wp:#{req.ip}") == true || req.path.match?(WP_PATHS)
  end

  track("track wp scanners", limit: max_suspicious_requests, period: track_time) do |req|
    if req.path.match?(WP_PATHS)
      if (Rails.cache.increment("track-wp-scanners:#{req.ip}", 1, expires_in: track_time) || 0) >= max_suspicious_requests
        Rails.cache.write("rack_attack:block_wp:#{req.ip}", true, expires_in: 1.year)
      end
      req.ip
    end
  end

  # Block PHP file access attempts
  blocklist("block php scanners") do |req|
    req.path.match?(/\.php$/i)
  end

  blocklist("block bad UA strings") do |req|
    req.user_agent&.match?(/^.*(masscan|nikto|nmap|sqlmap|wget|curl|python-requests).*$/i)
  end

  Rack::Attack.blocklisted_responder = lambda do |request|
    case request.env["rack.attack.matched"]
    when "block wordpress scanners"
      [ 403, { "Content-Type" => "text/plain" }, [ "Blocked: This site is not WordPress.\n" ] ]
    when "block php scanners"
      [ 404, { "Content-Type" => "text/plain" }, [ "Not Found\n" ] ]
    else
      [ 403, { "Content-Type" => "text/plain" }, [ "Forbidden\n" ] ]
    end
  end
end
