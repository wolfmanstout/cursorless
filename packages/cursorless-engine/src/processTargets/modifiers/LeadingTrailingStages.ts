import type { LeadingModifier, TrailingModifier } from "@cursorless/common";
import type { Target } from "../../typings/target.types";
import type { ModifierStageFactory } from "../ModifierStageFactory";
import type {
  ModifierStage,
  ModifierStateOptions,
} from "../PipelineStages.types";
import { containingTokenIfUntypedModifier } from "./commonContainingScopeIfUntypedModifiers";

/**
 * Throw this error if user has requested leading or trailing delimiter but no
 * such delimiter exists on the given target.
 */
class NoDelimiterError extends Error {
  constructor(type: "leading" | "trailing") {
    super(`Target has no ${type} delimiter.`);
    this.name = "NoDelimiterError";
  }
}

export class LeadingStage implements ModifierStage {
  constructor(
    private modifierStageFactory: ModifierStageFactory,
    private modifier: LeadingModifier,
  ) {}

  run(target: Target, options: ModifierStateOptions): Target[] {
    return this.modifierStageFactory
      .create(containingTokenIfUntypedModifier)
      .run(target, options)
      .map((target) => {
        const leading = target.getLeadingDelimiterTarget();
        if (leading == null) {
          throw new NoDelimiterError("leading");
        }
        return leading;
      });
  }
}

export class TrailingStage implements ModifierStage {
  constructor(
    private modifierStageFactory: ModifierStageFactory,
    private modifier: TrailingModifier,
  ) {}

  run(target: Target, options: ModifierStateOptions): Target[] {
    return this.modifierStageFactory
      .create(containingTokenIfUntypedModifier)
      .run(target, options)
      .map((target) => {
        const trailing = target.getTrailingDelimiterTarget();
        if (trailing == null) {
          throw new NoDelimiterError("trailing");
        }
        return trailing;
      });
  }
}
