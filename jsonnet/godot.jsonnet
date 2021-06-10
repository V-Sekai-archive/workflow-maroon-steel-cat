local HEADLESS_SERVER_EDITOR = 'godot_server.x11.opt.tools.64.llvm';

local platform_info_dict = {
  windows: {
    platform_name: 'windows',
    scons_env: 'PATH=/opt/llvm-mingw/bin:$PATH ',
    intermediate_godot_binary: 'godot.windows.opt.tools.64.exe',
    editor_godot_binary: 'godot.windows.opt.tools.64.exe',
    template_debug_binary: 'windows_64_debug.exe',
    template_release_binary: 'windows_64_release.exe',
    export_directory: 'export_windows',
    scons_platform: 'windows',
    gdnative_platform: 'windows',
    strip_command: 'mingw-strip --strip-debug',
    godot_scons_arguments: "use_mingw=yes use_llvm=yes use_lld=yes use_thinlto=yes LINKFLAGS=-Wl,-pdb= CCFLAGS='-g -gcodeview' debug_symbols=no",
    extra_commands: [],
    environment_variables: [],
    template_artifacts_override: null,
    template_output_artifacts: null,
    template_extra_commands: [],
  },
  linux: {
    platform_name: 'linux',
    scons_env: '',
    intermediate_godot_binary: 'godot.x11.opt.tools.64.llvm',
    editor_godot_binary: 'godot.x11.opt.tools.64.llvm',
    template_debug_binary: 'linux_x11_64_debug',
    template_release_binary: 'linux_x11_64_release',
    export_directory: 'export_linux_x11',
    scons_platform: 'x11',
    gdnative_platform: 'linux',
    strip_command: 'strip --strip-debug',
    godot_scons_arguments: 'use_static_cpp=yes use_llvm=yes builtin_freetype=yes',
    extra_commands: [],
    environment_variables: [],
    template_artifacts_override: null,
    template_output_artifacts: null,
    template_extra_commands: [],
  },
  server: {
    platform_name: 'server',
    scons_env: '',
    intermediate_godot_binary: HEADLESS_SERVER_EDITOR,
    editor_godot_binary: HEADLESS_SERVER_EDITOR,
    template_debug_binary: 'server_64_debug',
    template_release_binary: 'server_64_release',
    export_directory: 'export_linux_server',
    scons_platform: 'server',
    gdnative_platform: 'linux',
    strip_command: 'strip --strip-debug',
    godot_scons_arguments: 'use_static_cpp=yes use_llvm=yes',  // FIXME: use_llvm=yes????
    extra_commands: [],
    environment_variables: [],
    template_artifacts_override: null,
    template_output_artifacts: null,
    template_extra_commands: [],
  },
  web: {
    platform_name: 'web',
    scons_env: 'source /opt/emsdk/emsdk_env.sh && EM_CACHE=/tmp ',
    intermediate_godot_binary: 'godot.javascript.opt.debug.zip',
    editor_godot_binary: null,
    template_debug_binary: 'webassembly_debug.zip',
    template_release_binary: 'webassembly_release.zip',
    strip_command: null,  // unknown if release should be built separately.
    scons_platform: 'javascript',
    gdnative_platform: 'linux', // TODO: We need godot_speech for web.
    godot_scons_arguments: 'use_llvm=yes builtin_freetype=yes',
    extra_commands: [],
    environment_variables: [],
    template_artifacts_override: null,
    template_output_artifacts: null,
    template_extra_commands: [],
  },
  macos: {
    platform_name: 'macos',
    scons_env: 'OSXCROSS_ROOT="LD_LIBRARY_PATH=/opt/osxcross/target/bin /opt/osxcross" ',
    intermediate_godot_binary: 'godot.osx.opt.tools.64',
    editor_godot_binary: 'godot.osx.opt.tools.64',
    template_debug_binary: 'godot_osx_debug.64',
    template_release_binary: 'godot_osx_release.64',
    scons_platform: 'osx',
    gdnative_platform: 'osx',
    strip_command: 'LD_LIBRARY_PATH=/opt/osxcross/target/bin /opt/osxcross/target/bin/x86_64-apple-darwin19-strip -S',
    // FIXME: We should look into using osx_tools.app instead of osx_template.app, because we build with tools=yes
    godot_scons_arguments: 'osxcross_sdk=darwin19 CXXFLAGS="-Wno-deprecated-declarations -Wno-error " builtin_freetype=yes',
    extra_commands: [],
    environment_variables: [
      {
        name: 'PATH',
        value: '/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin',
      },
    ],
    template_artifacts_override: [
      {
        type: 'build',
        source: 'g/bin/osx.zip',
        destination: '',
      },
      {
        type: 'build',
        source: 'Godot.app',
        destination: '',
      },
      {
        type: 'build',
        source: 'g/bin/version.txt',
        destination: '',
      },
    ],
    template_output_artifacts: ['osx.zip'],
    template_extra_commands: [
      'rm -rf ./bin/osx_template.app',
      'cp -r ./misc/dist/osx_template.app ./bin/',
      'mkdir -p ./bin/osx_template.app/Contents/MacOS',
      'mv ./bin/godot_osx_debug.64 ./bin/osx_template.app/Contents/MacOS/godot_osx_debug.64',
      'chmod +x ./bin/osx_template.app/Contents/MacOS/godot_osx_debug.64',
      'mv ./bin/godot_osx_release.64 ./bin/osx_template.app/Contents/MacOS/godot_osx_release.64',
      'chmod +x ./bin/osx_template.app/Contents/MacOS/godot_osx_release.64',
      'rm -rf bin/osx.zip',
      'cd bin && zip -9 -r osx.zip osx_template.app/',
      'cd .. && rm -rf Godot.app && cp -r ./g/misc/dist/osx_template.app Godot.app',
    ],
  },
};

local enabled_engine_platforms = [platform_info_dict[x] for x in ['windows', 'linux', 'server', 'macos']];

local enabled_template_platforms = [platform_info_dict[x] for x in ['windows', 'linux', 'server', 'web', 'macos']];

local enabled_gdnative_platforms = [platform_info_dict[x] for x in ['windows', 'linux', 'macos']];


local groups_gdnative_plugins = {
  godot_speech: {
    name: 'godot_speech',
    pipeline_name: 'gdnative-godot-speech',
    git_url: 'https://github.com/V-Sekai/godot_speech.git',
    git_branch: 'master',
    platforms: {
      windows: {
        artifacts: [
          'bin/release/libGodotSpeech.dll',
        ],
        output_artifacts: [
          'libGodotSpeech.dll',
        ],
        debug_artifacts: [
          'bin/release/libGodotSpeech.dbg.dll',
          'bin/release/libGodotSpeech.pdb',
        ],
        scons_arguments: '',
        environment_variables: [],
        prepare_commands: [],
        extra_commands: [
          'cd bin/release && mv libGodotSpeech.dll libGodotSpeech.dbg.dll && mingw-strip --strip-debug -o libGodotSpeech.dll libGodotSpeech.dbg.dll',
        ],
        //install_task: ["mv libGodotSpeech.dll g/addons/godot_speech/bin/libGodotSpeech.dll"],
      },
      linux: {
        artifacts: [
          'bin/release/libGodotSpeech.so',
        ],
        output_artifacts: [
          'libGodotSpeech.so',
        ],
        debug_artifacts: [
          'bin/release/libGodotSpeech.dbg.so',
        ],
        scons_arguments: '',
        environment_variables: [],
        prepare_commands: [],
        extra_commands: [
          'cd bin/release && mv libGodotSpeech.so libGodotSpeech.dbg.so && strip --strip-debug -o libGodotSpeech.so libGodotSpeech.dbg.so',
        ],
        //install_task: ["mv libGodotSpeech.so g/addons/godot_speech/bin/libGodotSpeech.so"],
      },
      osx: {
        artifacts: [
          "bin/release/libGodotSpeech.dylib"
        ],
        output_artifacts: [
          "libGodotSpeech.dylib"
        ],
        debug_artifacts: [
          "bin/release/libGodotSpeech.dbg.dylib"
        ],
        scons_arguments: '',
        environment_variables: [],
        prepare_commands: [],
        extra_commands: [
          "cd bin/release && mv libGodotSpeech.dylib libGodotSpeech.dbg.dylib && LD_LIBRARY_PATH=/opt/osxcross/target/bin /opt/osxcross/target/bin/x86_64-apple-darwin19-strip -S -o libGodotSpeech.dylib libGodotSpeech.dbg.dylib"
        ],
        //install_task: ["mv libGodotSpeech.dylib g/addons/godot_speech/bin/libGodotSpeech.dylib"],
      },
    },
  },
  godot_openvr: {
    name: 'godot_openvr',
    pipeline_name: 'gdnative-godot-openvr',
    git_url: 'https://github.com/V-Sekai/godot_openvr.git',
    git_branch: 'groups',
    platforms: {
      windows: {
        artifacts: [
          'demo/addons/godot-openvr/bin/win64/libgodot_openvr.dll',
          'demo/addons/godot-openvr/bin/win64/openvr_api.dll',
        ],
        output_artifacts: [
          'libgodot_openvr.dll',
          'openvr_api.dll',
        ],
        debug_artifacts: [
          'demo/addons/godot-openvr/bin/win64/libgodot_openvr.dbg.dll',
          'demo/addons/godot-openvr/bin/win64/libgodot_openvr.pdb',
        ],
        scons_arguments: '',
        environment_variables: [],
        // NOTE: We will use prebuilt openvr_api.dll
        prepare_commands: [
          'python wrap_openvr.py',
          'rm -f demo/addons/godot-openvr/bin/win64/libgodot_openvr.dll',
        ],
        extra_commands: [
          'cd demo/addons/godot-openvr/bin/win64 && mv libgodot_openvr.dll libgodot_openvr.dbg.dll && mingw-strip --strip-debug -o libgodot_openvr.dll libgodot_openvr.dbg.dll',
        ],
        //install_task: ["mv libGodotSpeech.dll g/addons/godot_speech/bin/libGodotSpeech.dll"],
      },
      linux: {
        artifacts: [
          'demo/addons/godot-openvr/bin/x11/libgodot_openvr.so',
          'demo/addons/godot-openvr/bin/x11/libopenvr_api.so',
        ],
        output_artifacts: [
          'libgodot_openvr.so',
          'libopenvr_api.so',
        ],
        debug_artifacts: [
          'demo/addons/godot-openvr/bin/x11/libgodot_openvr.dbg.so',
        ],
        scons_arguments: '',
        environment_variables: [],
        // NOTE: We will use prebuilt libopenvr_api.so
        prepare_commands: [
          'rm -f demo/addons/godot-openvr/bin/x11/libgodot_openvr.so',
        ],
        extra_commands: [
          'cd demo/addons/godot-openvr/bin/x11 && mv libgodot_openvr.so libgodot_openvr.dbg.so && strip --strip-debug -o libgodot_openvr.so libgodot_openvr.dbg.so',
        ],
        //install_task: ["mv libGodotSpeech.so g/addons/godot_speech/bin/libGodotSpeech.so"],
      },
      osx: {
        artifacts: [],
        output_artifacts: [],
        debug_artifacts: [],
        scons_arguments: ' --version',
        environment_variables: [],
        prepare_commands: [],
        extra_commands: [],
      }
    },
  },
  godot_gltf: {
    name: 'godot_gltf',
    pipeline_name: 'gdnative-godot-gltf',
    git_url: 'https://github.com/V-Sekai/godot-gltf-module.git',
    git_branch: 'gdnative',
    platforms: {
      windows: {
        artifacts: [
          'bin/release/libgodot_gltf.dll',
        ],
        output_artifacts: [
          'libgodot_gltf.dll',
        ],
        debug_artifacts: [
          'bin/release/libgodot_gltf.pdb',
        ],
        scons_arguments: '',
        environment_variables: [],
        prepare_commands: [],
        extra_commands: [
        ],
      },
      linux: {
        artifacts: [
          'bin/release/libgodot_gltf.so',
        ],
        output_artifacts: [
          'libgodot_gltf.so',
        ],
        debug_artifacts: [
          'bin/release/libgodot_gltf.dbg.so',
        ],
        scons_arguments: '',
        environment_variables: [],
        prepare_commands: [],
        extra_commands: [
          'cd bin/release && mv libgodot_gltf.so libgodot_gltf.dbg.so && strip --strip-debug -o libgodot_gltf.so libgodot_gltf.dbg.so',
        ],
      },
      osx: {
        artifacts: [
          "bin/release/libgodot_gltf.dylib"
        ],
        output_artifacts: [
          "libgodot_gltf.dylib"
        ],
        debug_artifacts: [
          "bin/release/libgodot_gltf.dbg.dylib"
        ],
        scons_arguments: '',
        environment_variables: [],
        prepare_commands: [],
        extra_commands: [
          "cd bin/release && mv libgodot_gltf.dylib libgodot_gltf.dbg.dylib && LD_LIBRARY_PATH=/opt/osxcross/target/bin /opt/osxcross/target/bin/x86_64-apple-darwin19-strip -S -o libgodot_gltf.dylib libgodot_gltf.dbg.dylib"
        ],
      },
    },
  },
};

// TODO: Use std.escapeStringBash in case export configurations wish to output executables with spaces.
local groups_export_configurations = {
  windows: {
    export_name: 'windows',
    platform_name: 'windows',
    gdnative_platform: 'windows',
    export_configuration: 'Windows Desktop',
    export_directory: 'export_windows',
    export_executable: 'v_sekai_windows.exe',
    itchio_out: 'windows-master',
    prepare_commands: [
      //'mingw-strip --strip-debug godot_speech/libGodotSpeech.dll',
      'cp -p godot_speech/libGodotSpeech.dll g/addons/godot_speech/bin/',
      //'strip --strip-debug godot_openvr/libgodot_openvr.dll',
      'cp -p godot_openvr/libgodot_openvr.dll godot_openvr/openvr_api.dll g/addons/godot-openvr/bin/win64/',
    ],
    extra_commands: [
      'cp -a g/assets/actions/openvr/actions export_windows/',
      'cp -p pdbs/*.pdb godot_speech/*.pdb godot_openvr/*.pdb export_windows/',
    ],
  },
  linuxDesktop: {
    export_name: 'linuxDesktop',
    platform_name: 'linux',
    gdnative_platform: 'linux',
    export_configuration: 'Linux/X11',
    export_directory: 'export_linux_x11',
    export_executable: 'v_sekai_linux_x11',
    itchio_out: 'x11-master',
    prepare_commands: [
      //'strip --strip-debug godot_speech/libGodotSpeech.so',
      'cp -p godot_speech/libGodotSpeech.so g/addons/godot_speech/bin/libGodotSpeech.so',
      //'strip --strip-debug godot_openvr/libgodot_openvr.so',
      'cp -p godot_openvr/libgodot_openvr.so godot_openvr/libopenvr_api.so g/addons/godot-openvr/bin/x11/',
    ],
    extra_commands: [
      'cp -a g/assets/actions/openvr/actions export_linux_x11/',
    ],
  },
  linuxServer: {
    export_name: 'linuxServer',
    platform_name: 'server',
    gdnative_platform: 'linux',
    export_configuration: 'Linux/Server',
    export_directory: 'export_linux_server',
    export_executable: 'v_sekai_linux_server',
    itchio_out: 'server-master',
    prepare_commands: [
      //'strip --strip-debug godot_speech/libGodotSpeech.so',
      'cp -p godot_speech/libGodotSpeech.so g/addons/godot_speech/bin/libGodotSpeech.so',
    ],
    extra_commands: [
      'rm -f export_linux_server/*.so',
    ],
  },
  macos: {
    export_name: 'macos',
    platform_name: 'macos',
    gdnative_platform: 'osx',
    export_configuration: 'Mac OSX',
    export_directory: 'export_macos',
    export_executable: 'v_sekai_macos.zip',
    itchio_out: 'macos',
    prepare_commands: [
      'cp -p godot_speech/libGodotSpeech.dylib g/addons/godot_speech/bin/libGodotSpeech.dylib',
      'sed -ibak -e "/mix_rate=48000/d" g/project.godot',
    ],
    extra_commands: [
      // https://itch.io/t/303643/cant-get-a-mac-app-to-run-after-butler-push-resolved
      'cd export_macos && unzip v_sekai_macos.zip && rm v_sekai_macos.zip',
    ],
  },
  web: {
    export_name: 'web',
    platform_name: 'web',
    gdnative_platform: 'linux',
    export_configuration: 'HTML5',
    export_directory: 'export_web',
    export_executable: 'v_sekai_web.html',
    itchio_out: null,
    prepare_commands: [
    ],
    extra_commands: [
    ],
  },
};

local all_gdnative_plugins = [groups_gdnative_plugins[x] for x in ['godot_speech', 'godot_openvr', 'godot_gltf']];

local enabled_groups_gdnative_plugins = [groups_gdnative_plugins[x] for x in ['godot_speech', 'godot_openvr']];

local enabled_groups_export_platforms = [groups_export_configurations[x] for x in ['windows', 'linuxDesktop', 'linuxServer', 'web', 'macos']];

local exe_to_pdb_path(binary) = (std.substr(binary, 0, std.length(binary) - 4) + '.pdb');

local godot_pipeline(pipeline_name='',
                     godot_status='',
                     godot_git='',
                     godot_branch='',
                     gocd_group='',
                     godot_modules_git='',
                     godot_modules_branch='') = {
  "apiVersion": "argoproj.io/v1alpha1",
  "kind": "Workflow",
  "metadata": {
    "generateName": pipeline_name + "-",
    "GODOT_STATUS": godot_status,
    "materials": [{
        name: "godot_sandbox",
        url: godot_git,
        type: 'git',
        branch: godot_branch,
        destination: 'g',    
      },
      if godot_modules_git != '' then
        {
          name: 'godot_custom_modules',
          url: godot_modules_git,
          type: 'git',
          branch: godot_modules_branch,
          destination: 'godot_custom_modules',
          shallow_clone: false,
        }
      else null,
    ]  
  },
  "spec": {
  "entrypoint": "artifact-example",
  "volumes": [
    {
      "name": "out",
      "hostPath": {
        "path": "/tmp/out",
        "type": "Directory"
      }
    }
  ],
  "templates": [],
  // {
  //   "name": "whalesay",
  //   "container": {
  //     "image": "docker/whalesay:latest",
  //     "command": [
  //       "sh",
  //       "-c"
  //     ],
  //     "args": [
  //       "cowsay hello world | tee /tmp/out/message_out"
  //     ],
  //     "volumeMounts": [
  //       {
  //         "mountPath": "/tmp/out",
  //         "name": "out"
  //       }
  //     ]
  //   }
  // },
  // {
  //   "name": "artifact-example",
  //   "dag": {
  //     "tasks": [
  //       {
  //         "name": "generate-artifact",
  //         "template": "whalesay"
  //       }
  //     ]
  //   }
  // },
  },
};
  // stages: [
  //   {
  //     name: 'defaultStage',
  //     clean_workspace: false,
  //     jobs: [
  //       {
  //         name: platform_info.platform_name + 'Job',
  //         resources: [
  //           'mingw5',
  //           'linux',
  //         ],
  //         artifacts: [
  //           {
  //             source: 'g/bin/' + platform_info.editor_godot_binary,
  //             destination: '',
  //             type: 'build',
  //           },
  //           if std.endsWith(platform_info.editor_godot_binary, '.exe') then {
  //             source: 'g/bin/' + exe_to_pdb_path(platform_info.editor_godot_binary),
  //             destination: '',
  //             type: 'build',
  //           } else null,
  //         ],
  //         environment_variables: platform_info.environment_variables,
  //         tasks: [
  //           {
  //             type: 'exec',
  //             arguments: [
  //               '-c',
  //               'sed -i "/^status =/s/=.*/= \\"$GODOT_STATUS.$GO_PIPELINE_COUNTER\\"/" version.py',
  //             ],
  //             command: '/bin/bash',
  //             working_directory: 'g',
  //           },
  //           {
  //             type: 'exec',
  //             arguments: [
  //               '-c',
  //               platform_info.scons_env + 'scons werror=no platform=' + platform_info.scons_platform + ' target=release_debug -j`nproc` use_lto=no deprecated=no ' + platform_info.godot_scons_arguments +
  //               if godot_modules_git != '' then ' custom_modules=../godot_custom_modules' else '',
  //             ],
  //             command: '/bin/bash',
  //             working_directory: 'g',
  //           },
  //           if platform_info.editor_godot_binary != platform_info.intermediate_godot_binary then
  //             {
  //               type: 'exec',
  //               arguments: [
  //                 '-c',
  //                 'cp -p g/bin/' + platform_info.intermediate_godot_binary + 'g/bin/' + platform_info.editor_godot_binary,
  //               ],
  //               command: '/bin/bash',
  //             }
  //           else null,
  //         ],
  //       }
  //       for platform_info in enabled_engine_platforms
  //     ],
  //   },
  //   {
  //     name: 'templateStage',
  //     jobs: [
  //       {
  //         name: platform_info.platform_name + 'Job',
  //         resources: [
  //           'linux',
  //           'mingw5',
  //         ],
  //         artifacts: if platform_info.template_artifacts_override != null then platform_info.template_artifacts_override else [
  //           {
  //             type: 'build',
  //             source: 'g/bin/' + platform_info.template_debug_binary,
  //             destination: '',
  //           },
  //           {
  //             type: 'build',
  //             source: 'g/bin/' + platform_info.template_release_binary,
  //             destination: '',
  //           },
  //           {
  //             type: 'build',
  //             source: 'g/bin/version.txt',
  //             destination: '',
  //           },
  //         ],
  //         environment_variables: platform_info.environment_variables,
  //         tasks: [
  //           {
  //             type: 'exec',
  //             arguments: [
  //               '-c',
  //               extra_command,
  //             ],
  //             command: '/bin/bash',
  //             working_directory: 'g',
  //           }
  //           for extra_command in platform_info.extra_commands
  //         ] + [
  //           {
  //             type: 'exec',
  //             arguments: [
  //               '-c',
  //               'sed -i "/^status =/s/=.*/= \\"$GODOT_STATUS.$GO_PIPELINE_COUNTER\\"/" version.py',
  //             ],
  //             command: '/bin/bash',
  //             working_directory: 'g',
  //           },
  //           if platform_info.editor_godot_binary == platform_info.intermediate_godot_binary then {
  //             type: 'fetch',
  //             artifact_origin: 'gocd',
  //             pipeline: pipeline_name,
  //             stage: 'defaultStage',
  //             job: platform_info.platform_name + 'Job',
  //             is_source_a_file: true,
  //             source: platform_info.intermediate_godot_binary,
  //             destination: 'g/bin/',
  //           } else {
  //             type: 'exec',
  //             arguments: [
  //               '-c',
  //               platform_info.scons_env + 'scons werror=no platform=' + platform_info.scons_platform + ' target=release_debug -j`nproc` use_lto=no deprecated=no ' + platform_info.godot_scons_arguments + if godot_modules_git != '' then ' custom_modules=../godot_custom_modules' else '',
  //             ],
  //             command: '/bin/bash',
  //             working_directory: 'g',
  //           },
  //           {
  //             type: 'exec',
  //             arguments: [
  //               '-c',
  //               'cp bin/' + platform_info.intermediate_godot_binary + ' bin/' + platform_info.template_debug_binary + ' && cp bin/' + platform_info.intermediate_godot_binary + ' bin/' + platform_info.template_release_binary + if platform_info.strip_command != null then ' && ' + platform_info.strip_command + ' bin/' + platform_info.template_release_binary else '',
  //             ],
  //             command: '/bin/bash',
  //             working_directory: 'g',
  //           },
  //           {
  //             type: 'exec',
  //             arguments: [
  //               '-c',
  //               'eval `sed -e "s/ = /=/" version.py` && declare "_tmp$patch=.$patch" "_tmp0=" "_tmp=_tmp$patch" && echo $major.$minor${!_tmp}.$GODOT_STATUS.$GO_PIPELINE_COUNTER > bin/version.txt',
  //             ],
  //             command: '/bin/bash',
  //             working_directory: 'g',
  //           },
  //         ] + [
  //           {
  //             type: 'exec',
  //             arguments: [
  //               '-c',
  //               extra_command,
  //             ],
  //             command: '/bin/bash',
  //             working_directory: 'g',
  //           }
  //           for extra_command in platform_info.template_extra_commands
  //         ],
  //       }
  //       for platform_info in enabled_template_platforms
  //     ],
  //   },
  //   {
  //     name: 'templateZipStage',
  //     jobs: [
  //       {
  //         name: 'defaultJob',
  //         resources: [
  //           'linux',
  //           'mingw5',
  //         ],
  //         artifacts: [
  //           {
  //             type: 'build',
  //             source: 'godot.templates.tpz',
  //             destination: '',
  //           },
  //         ],
  //         tasks: [
  //           {
  //             type: 'exec',
  //             arguments: [
  //               '-c',
  //               'rm -rf templates',
  //             ],
  //             command: '/bin/bash',
  //           },
  //           {
  //             type: 'fetch',
  //             artifact_origin: 'gocd',
  //             is_source_a_file: true,
  //             source: 'version.txt',
  //             destination: 'templates',
  //             pipeline: pipeline_name,
  //             stage: 'templateStage',
  //             job: enabled_template_platforms[0].platform_name + 'Job',
  //           },
  //           {
  //             type: 'fetch',
  //             artifact_origin: 'gocd',
  //             is_source_a_file: true,
  //             source: exe_to_pdb_path(platform_info_dict.windows.editor_godot_binary),
  //             destination: 'templates',
  //             pipeline: pipeline_name,
  //             stage: 'defaultStage',
  //             job: 'windowsJob',
  //           },
  //         ] + std.flatMap(function(platform_info) [
  //           {
  //             type: 'fetch',
  //             artifact_origin: 'gocd',
  //             is_source_a_file: true,
  //             source: output_artifact,
  //             destination: 'templates',
  //             pipeline: pipeline_name,
  //             stage: 'templateStage',
  //             job: platform_info.platform_name + 'Job',
  //           }
  //           for output_artifact in if platform_info.template_output_artifacts != null then platform_info.template_output_artifacts else [
  //             platform_info.template_debug_binary,
  //             platform_info.template_release_binary,
  //           ]
  //         ], enabled_template_platforms) + [
  //           {
  //             type: 'exec',
  //             arguments: [
  //               '-c',
  //               'rm -rf godot.templates.tpz',
  //             ],
  //             command: '/bin/bash',
  //           },
  //           {
  //             type: 'exec',
  //             arguments: [
  //               '-c',
  //               'zip -9 godot.templates.tpz templates/*',
  //             ],
  //             command: '/bin/bash',
  //           },
  //         ],
  //       },
  //     ],

// Groups
local godot_template_groups_editor = 'godot-template-groups';
local godot_cpp_pipeline = 'gdnative-cpp';
local godot_template_groups_export = 'production-groups-release-export';
local docker_pipeline = 'docker-groups';
local docker_uro_pipeline = 'docker-uro';
local docker_video_decoder_pipeline = 'docker-video-decoder';
// CHIBIFIRE
local godot_template_chibifire_editor = 'godot-template-chibifire';
// STERN FLOWERS
local godot_template_stern_flowers_editor = 'godot-template-stern-flowers';
// END
local godot_gdnative_pipelines =
  [plugin_info.pipeline_name for plugin_info in all_gdnative_plugins];

{
  // CHIBIFIRE
  'godot_chibifire_editor.gopipeline.json'
  : std.prune(godot_pipeline(
    pipeline_name=godot_template_chibifire_editor,
    godot_status='chibifire',
    godot_git='https://github.com/godot-extended-libraries/godot-fire.git',
    godot_branch='extended-fire',
    gocd_group='chibifire',
    godot_modules_git='https://github.com/godot-extended-libraries/godot-modules-fire.git',
    godot_modules_branch='master',
  )),
  // STERN FLOWERS
  'godot_stern_flowers_editor.gopipeline.json'
  : std.prune(godot_pipeline(
    pipeline_name=godot_template_stern_flowers_editor,
    godot_status='stern-flowers',
    godot_git='https://github.com/godotengine/godot.git',
    godot_branch='master',
    gocd_group='stern-flowers'
  )),
  // GROUPS
  'godot_groups_editor.gopipeline.json'
  : std.prune(godot_pipeline(
    pipeline_name=godot_template_groups_editor,
    godot_status='groups',
    godot_git='https://github.com/V-Sekai/godot.git',
    godot_branch='groups',
    gocd_group='beta',
    godot_modules_git='https://github.com/V-Sekai/godot-modules-groups.git',
    godot_modules_branch='groups',
  )),
  // 'gdnative_cpp.gopipeline.json'
  // : std.prune(
  //   generate_godot_cpp_pipeline(
  //     pipeline_name=godot_cpp_pipeline,
  //     pipeline_dependency=godot_template_groups_editor,
  //     gocd_group='beta',
  //     godot_status='gdnative.godot-cpp'
  //   )
  // ),
}
