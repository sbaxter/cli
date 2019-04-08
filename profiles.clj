{:user     {:aliases      {"integration" ["do" "clean" ["uberjar"] ["with-profile" "+integration" "test"]]
                           "lint"        ["do" "clean" ["kibit"] ["eastwood"] ["bikeshed" "-v"]]
                           "proj"        ["do" "clean" ["deps" ":tree"] ["ancient"]]
                           "omni"        ["do" "clean" ["deps" ":tree"] ["ancient"] ["kibit"] ["eastwood"] ["bikeshed"]]}
            :dependencies [[nrepl "0.6.0"]]
            :jvm-opts     ["-Dapple.awt.UIElement=true"]
            :plugins      [[cider/cider-nrepl "0.21.1"]
                           [jonase/eastwood "0.3.5"]
                           [lein-ancient "0.6.15"]
                           [lein-bikeshed "0.5.2"]
                           [lein-difftest "2.0.0"]
                           [lein-kibit "0.1.6"]
                           [lein-pprint "1.2.0"]
                           [lein-try "0.4.3"]
                           [com.roomkey/lein-v "7.1.0"]]}
 :pedantic {:pedantic? :abort}}
