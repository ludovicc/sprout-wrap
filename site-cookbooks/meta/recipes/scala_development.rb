# TODO: add a recipe to install JDK7 from Oracle, this is Java 6 from Apple
include_recipe "pivotal_workstation::java"
include_recipe "sprout-osx-apps::intellij_ultimate_edition"
include_recipe "scala_workstation::akka"
include_recipe "scala_workstation::sbt"
include_recipe "scala_workstation::giter8"
#TODO include_recipe "pivotal_workstation::elasticsearch"
#TODO include_recipe "pivotal_workstation::groovy"
