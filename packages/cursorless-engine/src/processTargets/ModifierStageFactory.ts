import type {
  ContainingScopeModifier,
  EveryScopeModifier,
  Modifier,
} from "@cursorless/common";
import type { ModifierStage } from "./PipelineStages.types";

export interface ModifierStageFactory {
  create(modifier: Modifier): ModifierStage;
  getLegacyScopeStage(
    modifier: ContainingScopeModifier | EveryScopeModifier,
  ): ModifierStage;
}
