require 'open-uri'

namespace :kinesis do
  JAR_DIR = 'jars'
  directory JAR_DIR

  def get_maven_jar_info(group_id, artifact_id, version)
    jar_name = "#{artifact_id}-#{version}.jar"
    jar_url = "http://repo1.maven.org/maven2/#{group_id.gsub(/\./, '/')}/#{artifact_id}/#{version}/#{jar_name}"
    local_jar_file = File.join(JAR_DIR, jar_name)
    [jar_name, jar_url, local_jar_file]
  end

  def download_maven_jar(group_id, artifact_id, version)
    jar_name, jar_url, local_jar_file = get_maven_jar_info(group_id, artifact_id, version)
    open(jar_url) do |remote_jar|
      open(local_jar_file, 'w') do |local_jar|
        IO.copy_stream(remote_jar, local_jar)
      end
    end
  end

  MAVEN_PACKAGES = [
    # (group id, artifact id, version),
    ['com.amazonaws', 'amazon-kinesis-client', '1.7.4'],
    ['com.amazonaws', 'aws-java-sdk-dynamodb', '1.11.14'],
    ['com.amazonaws', 'aws-java-sdk-s3', '1.11.14'],
    ['com.amazonaws', 'aws-java-sdk-kms', '1.11.14'],
    ['com.amazonaws', 'aws-java-sdk-core', '1.11.14'],
    ['commons-logging', 'commons-logging', '1.1.3'],
    ['org.apache.httpcomponents', 'httpclient', '4.5.2'],
    ['org.apache.httpcomponents', 'httpcore', '4.4.4'],
    ['commons-codec', 'commons-codec', '1.9'],
    ['com.fasterxml.jackson.core', 'jackson-databind', '2.6.6'],
    ['com.fasterxml.jackson.core', 'jackson-annotations', '2.6.0'],
    ['com.fasterxml.jackson.core', 'jackson-core', '2.6.6'],
    ['com.fasterxml.jackson.dataformat', 'jackson-dataformat-cbor', '2.6.6'],
    ['joda-time', 'joda-time', '2.8.1'],
    ['com.amazonaws', 'aws-java-sdk-kinesis', '1.11.14'],
    ['com.amazonaws', 'aws-java-sdk-cloudwatch', '1.11.14'],
    ['com.google.guava', 'guava', '18.0'],
    ['com.google.protobuf', 'protobuf-java', '2.6.1'],
    ['commons-lang', 'commons-lang', '2.6']
  ]

  task download_jars: [JAR_DIR]

  MAVEN_PACKAGES.each do |jar|
    _, _, local_jar_file = get_maven_jar_info(*jar)
    file local_jar_file do
      puts "Downloading '#{local_jar_file}' from maven..."
      download_maven_jar(*jar)
    end
    task download_jars: local_jar_file
  end

  desc 'Run KCL consumer'
  task :run, [:processor] => [:download_jars] do |_t, args|
    puts 'Running the Kinesis consumer...'
    classpath = FileList["#{JAR_DIR}/*.jar"].join(':')
    env = ENV['RAILS_ENV'] || 'development'
    ENV['AWS_CBOR_DISABLE'] = 'true' if env == 'development'
    ENV['KINESIS_PROCESSOR'] = args[:processor]
    commands = %W(
    java
    -classpath #{classpath}
    com.amazonaws.services.kinesis.multilang.MultiLangDaemon kcl-#{env}.properties
  )
    sh(*commands)
  end

end
