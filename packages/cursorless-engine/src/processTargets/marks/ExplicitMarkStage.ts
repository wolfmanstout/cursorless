import type { ExplicitMark } from "@cursorless/common";
import { Range } from "@cursorless/common";
import type { Target } from "../../typings/target.types";
import type { MarkStage } from "../PipelineStages.types";
import { UntypedTarget } from "../targets";
import { ide } from "../../singletons/ide.singleton";

export class ExplicitMarkStage implements MarkStage {
  constructor(private mark: ExplicitMark) {}

  run(): Target[] {
    const {
      editorId,
      range: { start, end },
    } = this.mark;

    const editor = ide().visibleTextEditors.find((e) => e.id === editorId);

    if (editor == null) {
      throw new Error(`Couldn't find editor '${editorId}'`);
    }

    const contentRange = new Range(
      start.line,
      start.character,
      end.line,
      end.character,
    );

    return [
      new UntypedTarget({
        editor,
        contentRange,
        isReversed: false,
        hasExplicitRange: false,
      }),
    ];
  }
}
