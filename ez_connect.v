module v_llama_cpp

import net.http
import time

fn check_speed(url string, timeout_ms time.Duration, ch chan string) {
	http.fetch(http.FetchConfig{
		url: url
		method: .head
		read_timeout: timeout_ms * time.second
	}) or {
		return
	}
	ch <- url
}

fn select_fastest_url(urls []string, timeout_ms int) !string {
	if urls.len == 0 {
		return error('[Error] ./v_llama_cpp/ez_connect.v select_fastest_url(): not found url.')
	}

	ch := chan string{cap: urls.len}

	for url in urls {
		go check_speed(url, timeout_ms * time.second, ch)
	}

	select {
		winner := <-ch {
			return winner
		}
		timeout_ms * time.second {
			return error('[Error] ./v_llama_cpp/ez_connect.v select_fastest_url(): timeout, not found url.')
		}
	}
	return error('[Error] ./v_llama_cpp/ez_connect.v select_fastest_url(): unexpected end of select.')
}
