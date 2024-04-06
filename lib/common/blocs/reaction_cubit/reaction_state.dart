part of 'reaction_cubit.dart';

class ReactionState extends Equatable {
  ReactionState({
    Map<Emoji, Emotion> reactions = const {},
    this.lastEmoji,
  }) : _reactions = Map<Emoji, Emotion>.fromEntries(reactions.entries);

  final Map<Emoji, Emotion> _reactions;
  final Emoji? lastEmoji;

  Map<Emoji, Emotion> get reactions => _reactions;

  @override
  List<Object?> get props => [DateTime.now()];
}

class ReactionStateOnTapMemberInEmotionShowDialogLoading extends ReactionState {
  ReactionStateOnTapMemberInEmotionShowDialogLoading();

  @override
  List<Object> get props => [];
}

class ReactionStateOnTapMemberInEmotionShowDialogLoaded extends ReactionState {
  ReactionStateOnTapMemberInEmotionShowDialogLoaded({
    required this.conversationId,
  });

  final int conversationId;

  @override
  List<Object> get props => [conversationId];
}

class ReactionStateOnTapMemberInEmotionShowDialogError extends ReactionState {
  ReactionStateOnTapMemberInEmotionShowDialogError({required this.error});

  final String error;

  @override
  List<Object> get props => [error];
}

class ReactionStateChangeReactionLoading extends ReactionState {
  ReactionStateChangeReactionLoading();

  @override
  List<Object> get props => [];
}

class ReactionStateCalculateEmotionBarSizeAndMessageWidthAfterReacted
    extends ReactionState {
  ReactionStateCalculateEmotionBarSizeAndMessageWidthAfterReacted();

  @override
  List<Object> get props => [];
}

class ReactionStateChangeReactionSuccess extends ReactionState {
  ReactionStateChangeReactionSuccess({
    // required this.reactions,
    // this.lastEmoji,
    required this.messageModel,
  });

  // @override
  // final Map<Emoji, Emotion> reactions;
  // @override
  // final Emoji? lastEmoji;
  final SocketSentMessageModel messageModel;

  @override
  // List<Object?> get props => [reactions, lastEmoji];
  List<Object?> get props => [messageModel];
}

class ReactionStateChangeReactionError extends ReactionState {
  final ExceptionError error;

  ReactionStateChangeReactionError(this.error);

  @override
  List<Object> get props => [DateTime.now()];
}
