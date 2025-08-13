import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'bloc/soundbloc.dart' as testbloc;
import 'package:clarity/view/Sound page/bloc/soundevent.dart';
import 'package:clarity/view/Sound page/bloc/soundstate.dart';
import 'remix.dart';
import 'sound_tile.dart';

class SoundPage extends StatelessWidget {
  const SoundPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          testbloc.SoundBloc(firestore: FirebaseFirestore.instance)
            ..add(LoadSounds()),
      child: const _SoundView(),
    );
  }
}

class _SoundView extends StatelessWidget {
  const _SoundView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocBuilder<testbloc.SoundBloc, SoundState>(
        builder: (context, state) {
          if (state is SoundInitial || state is SoundLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is SoundError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(state.message),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () =>
                        context.read<testbloc.SoundBloc>().add(LoadSounds()),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          if (state is SoundLoaded) {
            final sounds = state.sounds;
            final selectedSounds = sounds.where((s) => s.isSelected).toList();
            final isPlaying = context
                .read<testbloc.SoundBloc>()
                .isAnySoundPlaying();

            return Column(
              children: [
                Expanded(
                  child: RefreshIndicator(
                    onRefresh: () async {
                      context.read<testbloc.SoundBloc>().add(RefreshSounds());
                    },
                    child: sounds.isEmpty
                        ? SingleChildScrollView(
                            physics: const AlwaysScrollableScrollPhysics(),
                            child: SizedBox(
                              height: MediaQuery.of(context).size.height,
                              child: const Center(
                                child: Text('No sounds available'),
                              ),
                            ),
                          )
                        : ListView.builder(
                            physics: const AlwaysScrollableScrollPhysics(),
                            itemCount: sounds.length,
                            itemBuilder: (context, index) {
                              return Column(
                                children: [
                                  const Divider(),
                                  SoundTile(
                                    sound: sounds[index],
                                    onTap: () => context
                                        .read<testbloc.SoundBloc>()
                                        .add(ToggleSoundSelection(index)),
                                  ),
                                  if (index == sounds.length - 1)
                                    const Divider(),
                                ],
                              );
                            },
                          ),
                  ),
                ),
                if (selectedSounds.isNotEmpty)
                  RelaxationMixBar(
                    onArrowTap: () {},
                    onPlay: () =>
                        context.read<testbloc.SoundBloc>().playAllSelected(),
                    onPause: () =>
                        context.read<testbloc.SoundBloc>().pauseAllSelected(),
                    imagePath: 'assets/images/remix_image.png',
                    soundCount: selectedSounds.length,
                    isPlaying: isPlaying,
                  ),
              ],
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }
}

// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:clarity/model/sound_model.dart';
// import 'soundbloc.dart';
// import 'soundevent.dart';
// import 'soundstate.dart';
// import 'soundt.dart';
// import 'remix.dart';

// class SoundPage extends StatelessWidget {
//   const SoundPage({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return BlocProvider(
//       create: (context) =>
//           SoundBloc(firestore: FirebaseFirestore.instance)..add(LoadSounds()),
//       child: const _SoundView(),
//     );
//   }
// }

// class _SoundView extends StatelessWidget {
//   const _SoundView();

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: BlocBuilder<SoundBloc, SoundState>(
//         builder: (context, state) {
//           if (state is SoundInitial || state is SoundLoading) {
//             return const Center(child: CircularProgressIndicator());
//           }

//           if (state is SoundError) {
//             return Center(
//               child: Column(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   Text(state.message),
//                   const SizedBox(height: 16),
//                   ElevatedButton(
//                     onPressed: () =>
//                         context.read<SoundBloc>().add(LoadSounds()),
//                     child: const Text('Retry'),
//                   ),
//                 ],
//               ),
//             );
//           }

//           if (state is SoundLoaded) {
//             final sounds = state.sounds;
//             final selectedSounds = sounds.where((s) => s.isSelected).toList();

//             return Column(
//               children: [
//                 Expanded(
//                   child: RefreshIndicator(
//                     onRefresh: () async {
//                       context.read<SoundBloc>().add(RefreshSounds());
//                     },
//                     child: sounds.isEmpty
//                         ? SingleChildScrollView(
//                             physics: const AlwaysScrollableScrollPhysics(),
//                             child: SizedBox(
//                               height: MediaQuery.of(context).size.height,
//                               child: const Center(
//                                 child: Text('No sounds available'),
//                               ),
//                             ),
//                           )
//                         : ListView.builder(
//                             physics: const AlwaysScrollableScrollPhysics(),
//                             itemCount: sounds.length,
//                             itemBuilder: (context, index) {
//                               return Column(
//                                 children: [
//                                   const Divider(),
//                                   SoundTile(
//                                     sound: sounds[index],
//                                     onTap: () => context.read<SoundBloc>().add(
//                                       ToggleSoundSelection(index),
//                                     ),
//                                   ),
//                                   if (index == sounds.length - 1)
//                                     const Divider(),
//                                 ],
//                               );
//                             },
//                           ),
//                   ),
//                 ),
//                 if (selectedSounds.isNotEmpty)
//                   RelaxationMixBar(
//                     onArrowTap: () {},
//                     onPlay: () => context.read<SoundBloc>().playAllSelected(),
//                     onPause: () => context.read<SoundBloc>().pauseAllSelected(),
//                     imagePath: 'assets/images/remix_image.png',
//                     soundCount: selectedSounds.length,
//                     isPlaying: context.read<SoundBloc>().isAnySoundPlaying(),
//                   ),
//               ],
//             );
//           }

//           return const SizedBox.shrink();
//         },
//       ),
//     );
//   }
// }
