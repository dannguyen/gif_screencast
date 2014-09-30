# Gif Screencast


Just a wrapper around ffmpeg and imagemagick to quickly add annotations to instructional animated GIFs and such.




### Draft notes

Possible config file:

```yaml
name:
  default:
    fps: "10%" # 10% or 5
    delay: 0.200
annotations:
  - at: "1:23"
    delay: 2
    text: "Hello world"
  - at: "2:23.50"
    text: "Another thing"
    tween:
      start: "2:23"
      end: "2:25"

tweens:
  - start: 3
    end: 5
    time_compression:
```
