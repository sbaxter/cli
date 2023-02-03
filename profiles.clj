{:user     {:aliases      {"integration" ["do" "clean" ["uberjar"] ["with-profile" "+integration" "test"]]
                           "lint"        ["do" "clean" ["kibit"] ["eastwood"] ["bikeshed" "-v"]]
                           "proj"        ["do" "clean" ["deps" ":tree"] ["ancient"]]
                           "omni"        ["do" "clean" ["deps" ":tree"] ["ancient"] ["kibit"] ["eastwood"] ["bikeshed"]]}
            :dependencies [[nrepl "1.0.0"]]
            :jvm-opts     ["-Dapple.awt.UIElement=true"]
            :plugins      [[cider/cider-nrepl "0.30.0"]
                           [jonase/eastwood "1.3.0"]
                           [lein-ancient "0.7.0"]
                           [lein-bikeshed "0.5.2"]
                           [lein-difftest "2.0.0"]
                           [lein-kibit "0.1.8"]
                           [lein-pprint "1.3.2"]
                           [lein-try "0.4.3"]
                           [com.roomkey/lein-v "7.2.0"]]}
 :pedantic {:pedantic? :abort}}
